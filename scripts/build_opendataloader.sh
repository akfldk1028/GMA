#!/bin/bash
# Build opendataloader-pdf CLI jar from submodule.
#
# Prerequisites: Java 11+, Maven 3.6+
# Usage: bash scripts/build_opendataloader.sh
#
# The jar stays in the Maven target/ directory.
# PdfStructureService finds it there during development.
# For release builds, copy it next to the exe: <exe>/bin/opendataloader-pdf-cli.jar

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SUBMODULE_DIR="$PROJECT_ROOT/frontend/vendor/opendataloader-pdf"
JAVA_DIR="$SUBMODULE_DIR/java"

# Verify submodule exists
if [ ! -d "$JAVA_DIR" ]; then
  echo "ERROR: opendataloader-pdf submodule not found at $SUBMODULE_DIR"
  echo "Run: git submodule update --init"
  exit 1
fi

# Verify Java
if ! command -v java &>/dev/null; then
  echo "ERROR: Java not found. Install JDK 11+ from https://adoptium.net/"
  exit 1
fi

# Verify Maven
if ! command -v mvn &>/dev/null; then
  echo "ERROR: Maven not found. Install Maven 3.6+ from https://maven.apache.org/"
  exit 1
fi

echo "Building opendataloader-pdf CLI jar..."
cd "$JAVA_DIR"
mvn package -pl opendataloader-pdf-cli -am -DskipTests -q

# Find the built jar
JAR_FILE=$(ls opendataloader-pdf-cli/target/opendataloader-pdf-cli-*.jar 2>/dev/null | grep -v sources | grep -v javadoc | head -1)

if [ -z "$JAR_FILE" ]; then
  echo "ERROR: Built jar not found in opendataloader-pdf-cli/target/"
  exit 1
fi

echo "SUCCESS: $JAR_FILE"
echo "Size: $(du -h "$JAR_FILE" | cut -f1)"
echo ""
echo "For development: PdfStructureService auto-discovers this jar."
echo "For release: copy to <exe_dir>/bin/opendataloader-pdf-cli.jar"
