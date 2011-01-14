all:
	@mkdir -p build
	cd build && cmake $(CMAKE_FLAGS) ..
	cd build && make
clean:
	rm -rf build
