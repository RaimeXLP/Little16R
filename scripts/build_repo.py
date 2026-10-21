#!/usr/bin/env python3
"""Build a flat Sileo/APT repository, retaining immutable package downloads."""

import argparse
import bz2
from datetime import datetime, timezone
from email.utils import format_datetime
import gzip
import hashlib
import io
import json
import lzma
from pathlib import Path
import shutil
import tarfile


PACKAGE_ID = "io.github.raimexlp.little16r"
ARCHITECTURE = "iphoneos-arm"


def package_control(package):
    """Read metadata without extracting package files into the filesystem."""
    data = package.read_bytes()
    if not data.startswith(b"!<arch>\n"):
        raise ValueError(f"Invalid Debian archive in {package}")
    offset = 8
    control_archives = []
    while offset < len(data):
        header = data[offset:offset + 60]
        if len(header) != 60 or header[-2:] != b"`\n":
            raise ValueError(f"Invalid archive header in {package}")
        name = header[:16].decode("ascii").strip().rstrip("/")
        size = int(header[48:58])
        offset += 60
        member = data[offset:offset + size]
        if size < 0 or len(member) != size:
            raise ValueError(f"Truncated archive member in {package}")
        offset += size + size % 2
        # Accept BSD long-name headers as well as ordinary Debian/SysV headers.
        if name.startswith("#1/"):
            name_size = int(name[3:])
            name = member[:name_size].rstrip(b"\0").decode("ascii")
            member = member[name_size:]
        if name.startswith("control.tar"):
            control_archives.append(member)
    if len(control_archives) != 1:
        raise ValueError(f"Expected one control archive in {package}")
    with tarfile.open(fileobj=io.BytesIO(control_archives[0]), mode="r:*") as archive:
        controls = [member for member in archive if member.name in ("control", "./control")]
        if len(controls) != 1 or not controls[0].isfile():
            raise ValueError(f"Expected one control file in {package}")
        control = archive.extractfile(controls[0]).read().decode("utf-8").strip()
    fields = {}
    for line in control.splitlines():
        if line.startswith((" ", "\t")):
            continue
        name, separator, value = line.partition(":")
        if not separator or name in fields:
            raise ValueError(f"Invalid control metadata in {package}")
        fields[name] = value.strip()
    if fields.get("Package") != PACKAGE_ID or fields.get("Architecture") != ARCHITECTURE:
        raise ValueError(f"Unexpected package identity or architecture in {package}")
    if not fields.get("Version"):
        raise ValueError(f"Missing package version in {package}")
    if {"Filename", "Size", "MD5sum", "SHA1", "SHA256", "SHA512"} & fields.keys():
        raise ValueError(f"Repository-only fields present in {package}")
    return control, fields


def build_repository(packages, output, template, source_commit, build_url):
    incoming = sorted(packages.glob("*.deb"))
    if len(incoming) != 1:
        raise ValueError("Expected exactly one newly built .deb")
    _, incoming_fields = package_control(incoming[0])
    expected_name = f"{PACKAGE_ID}_{incoming_fields['Version']}_{ARCHITECTURE}.deb"
    if incoming[0].name != expected_name:
        raise ValueError("Package filename does not match its metadata")

    pool = output / "pool"
    pool.mkdir(parents=True, exist_ok=True)
    destination = pool / expected_name
    if destination.exists() and destination.read_bytes() != incoming[0].read_bytes():
        raise ValueError("Refusing to replace an existing package; use a new version")
    shutil.copyfile(incoming[0], destination)
    shutil.copytree(template, output, dirs_exist_ok=True)
    (output / ".nojekyll").touch()

    stanzas = []
    versions = set()
    for package in sorted(pool.glob("*.deb")):
        control, fields = package_control(package)
        if fields["Version"] in versions:
            raise ValueError("Duplicate package version in archive")
        versions.add(fields["Version"])
        data = package.read_bytes()
        stanza = f"{control}\nFilename: pool/{package.name}\nSize: {len(data)}\n"
        for field, algorithm in (("MD5sum", "md5"), ("SHA1", "sha1"),
                                 ("SHA256", "sha256"), ("SHA512", "sha512")):
            stanza += f"{field}: {hashlib.new(algorithm, data).hexdigest()}\n"
        stanzas.append(stanza + "\n")

    index = "".join(stanzas).encode("utf-8")
    indices = {
        "Packages": index,
        "Packages.gz": gzip.compress(index, mtime=0),
        "Packages.bz2": bz2.compress(index),
        "Packages.xz": lzma.compress(index),
    }
    release = (
        "Origin: Little16R by Leon Prinz\n"
        "Label: Little16R\n"
        "Suite: experimental\n"
        "Codename: little16r\n"
        "Architectures: iphoneos-arm\n"
        "Description: Experimental rootful iPhone 7 gesture navigation\n"
        f"Date: {format_datetime(datetime.now(timezone.utc), usegmt=True)}\n"
        "Acquire-By-Hash: yes\n"
    )
    for filename, data in indices.items():
        (output / filename).write_bytes(data)
    for field, algorithm in (("MD5Sum", "md5"), ("SHA1", "sha1"),
                             ("SHA256", "sha256"), ("SHA512", "sha512")):
        release += f"{field}:\n"
        for filename, data in indices.items():
            digest = hashlib.new(algorithm, data).hexdigest()
            release += f" {digest} {len(data)} {filename}\n"
            # Keep old indices as well, so clients can finish a cached update.
            archive = output / "by-hash" / field / digest
            archive.parent.mkdir(parents=True, exist_ok=True)
            archive.write_bytes(data)
    (output / "Release").write_text(release, encoding="utf-8")
    (output / "build-info.json").write_text(json.dumps({
        "package": PACKAGE_ID,
        "version": incoming_fields["Version"],
        "architecture": ARCHITECTURE,
        "source_commit": source_commit,
        "build_url": build_url,
        "sha256": hashlib.sha256(incoming[0].read_bytes()).hexdigest(),
    }, indent=2) + "\n", encoding="utf-8")
    print(f"Published metadata for {len(stanzas)} package version(s)")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--packages", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--template", type=Path, required=True)
    parser.add_argument("--source-commit", required=True)
    parser.add_argument("--build-url", required=True)
    arguments = parser.parse_args()
    build_repository(arguments.packages, arguments.output, arguments.template,
                     arguments.source_commit, arguments.build_url)
