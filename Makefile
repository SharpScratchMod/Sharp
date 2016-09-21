go:
	@echo Building Sharp...
	@.\gradlew build
	@echo Building complete

all: go dev
clean:
	@del "build\11.6\*" /Q
	@del "build\11.6dev\*" /Q
	@rmdir build\11.6
	@rmdir build\11.6dev
dev:
	@echo Building Sharp (Dev Mode)...
	@.\gradlew build -Ptarget=11.6dev
	@echo Building complete
help:
	@echo "nmake" for a shortcut for "nmake go"
	@echo.
	@echo "nmake go" to build Sharp
	@echo "nmake dev" to build Sharp with dev mode
	@echo "nmake all" to build Sharp normally and build Sharp with dev mode
	@echo "nmake clean" to clean out the build directory