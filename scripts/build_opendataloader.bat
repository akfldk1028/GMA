@echo off
REM Build opendataloader-pdf CLI jar from submodule.
REM Prerequisites: Java 11+, Maven 3.6+

setlocal

set SCRIPT_DIR=%~dp0
set PROJECT_ROOT=%SCRIPT_DIR%..
set SUBMODULE_DIR=%PROJECT_ROOT%\frontend\vendor\opendataloader-pdf
set JAVA_DIR=%SUBMODULE_DIR%\java

if not exist "%JAVA_DIR%" (
    echo ERROR: opendataloader-pdf submodule not found.
    echo Run: git submodule update --init
    exit /b 1
)

where java >nul 2>&1
if errorlevel 1 (
    echo ERROR: Java not found. Install JDK 11+ from https://adoptium.net/
    exit /b 1
)

where mvn >nul 2>&1
if errorlevel 1 (
    echo ERROR: Maven not found. Install Maven 3.6+ from https://maven.apache.org/
    exit /b 1
)

echo Building opendataloader-pdf CLI jar...
cd /d "%JAVA_DIR%"
call mvn package -pl opendataloader-pdf-cli -am -DskipTests -q

for %%f in (opendataloader-pdf-cli\target\opendataloader-pdf-cli-*.jar) do (
    echo %%f | findstr /v "sources javadoc" >nul && (
        echo SUCCESS: %%f
        echo.
        echo For development: PdfStructureService auto-discovers this jar.
        echo For release: copy to ^<exe_dir^>\bin\opendataloader-pdf-cli.jar
        goto :done
    )
)

echo ERROR: Built jar not found.
exit /b 1

:done
endlocal
