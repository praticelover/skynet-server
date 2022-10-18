# Top level makefile, the real shit is at src/Makefile
SRC_DIR = ./lualib-src
LIB_DIR = ./luaclib

SRC = ${wildcard ${SRC_DIR}/*.c}
LIB = ${patsubst lua-%.c, ${LIB_DIR}/%.so, ${notdir ${SRC}}}

all: skynet/skynet redis/redis-server ${LIB}

skynet/skynet:
	cd skynet && $(MAKE) linux

JEMALLOC_STATICLIB := redis/deps/jemalloc/lib/libjemalloc_pic.a
REDIS_SERVER := redis/src/redis-server

redis/redis-server: | $(REDIS_SERVER)
	cp $(REDIS_SERVER) redis/

$(REDIS_SERVER): | $(JEMALLOC_STATICLIB)
	cd redis && $(MAKE) MALLOC=libc

$(JEMALLOC_STATICLIB): redis/deps/jemalloc/Makefile
	cd redis/deps/jemalloc && $(MAKE) CC=$(CC) 

redis/deps/jemalloc/Makefile:
	cd redis/deps/jemalloc && find ./ -name "*.sh" | xargs chmod +x && ./autogen.sh --with-jemalloc-prefix=je_ --disable-valgrind

${LIB_DIR}/%.so:${SRC_DIR}/lua-%.c
	cc -g -O2 -Wall -Iskynet/3rd/lua -fPIC --shared $< -o $@ -lcurl

.PHONY:clean
clean:
	rm ${LIB}