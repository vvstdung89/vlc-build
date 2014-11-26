
VLC_VERSION=2.1.5
vlc_url=http://download.videolan.org/pub/videolan/vlc/${VLC_VERSION}/vlc-${VLC_VERSION}.tar.xz


echo "Start script. "

if [ "$1" == "heroku" ]; then
	ln -s /app/.apt/usr/bin/luac5.2 /app/.apt/usr/bin/luac
	cp /usr/include/xcb/xcb.h /app/.apt/usr/include/xcb/.
	cp /usr/include/xcb/xproto.h /app/.apt/usr/include/xcb/.
	cp /usr/include/xcb/render.h /app/.apt/usr/include/xcb/.
	cp /usr/include/xcb/shm.h /app/.apt/usr/include/xcb/.
	export CFLAGS_libmpeg2=-I/app/.apt/usr/include/mpeg2dec
	export CFLAGS_lua=-I/app/.apt/usr/include/lua5.2 -I/app/.apt/usr/include/x86_64-linux-gnu
	export LUA_CFLAGS=-I/app/.apt/usr/include/lua5.2 -I/app/.apt/usr/include/x86_64-linux-gnu
	cp  /app/.apt/usr/include/x86_64-linux-gnu/lua5.2-deb-multiarch.h /app/.apt/usr/include/lua5.2/.
	prefix = "/tmp/vlc";
	( cd /tmp ; python -m SimpleHTTPServer $PORT & )
else
	cat Aptfile | xargs sudo apt-get install -y
	sudo apt-get -y install libgcrypt20-dev 
	prefix="/usr/local"
fi

temp_dir=$(mktemp -d /tmp/vlc.XXXXXXXXXX)
cur_dir=`pwd`
cd $temp_dir

echo "Downloading $vlc_url"
(curl -L $vlc_url -O && tar xf vlc-${VLC_VERSION}.tar.xz && rm vlc-${VLC_VERSION}.tar.xz)

echo "Compile vlc"
(	
	cd $cur_dir	
	if (test -d vlc-${VLC_VERSION}); then
		echo "Copy file to /${temp_dir}/vlc-${VLC_VERSION}"
		cp -rf vlc-${VLC_VERSION}/* /${temp_dir}/vlc-${VLC_VERSION}/. 
	fi

	cd /${temp_dir}/vlc-${VLC_VERSION}
	./configure \
		--disable-glx \
		--enable-libgcrypt \
		--enable-dvbpsi \
		--enable-avcodec \
		--enable-avformat  \
		--enable-x264 \
		--disable-mad \
		--disable-swscale \
		--disable-a52 \
		--prefix=$prefix 
	

	if [ "$1" != "heroku" ]; then
		sudo make install
		cd /tmp
		tar -zcvf vlc.tar.gz /tmp/vlc
	else
		make install
	fi
)

ldconfig

while true
do
	sleep 10
	echo "."
done
