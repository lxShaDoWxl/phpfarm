#!/bin/bash
version=$1
#directory of this file. all php srces are extrated in it
basedir="`dirname "$0"`"
cd "$basedir"
basedir=`pwd`
#directory of php sources of specific version
srcdir="php-$version"
#directory with source archives
bzipsdir='bzips'
#directory phps get installed into
instbasedir="$basedir/../inst"
#directory this specific version gets installed into
instdir="$instbasedir/php-$version"
#directory where all bins are symlinked
shbindir="$instbasedir/bin"

#we need a php version
if [ "x$version" = 'x' ]; then
    echo 'Please specify php version'
    exit 1
fi


#already extracted?
if [ ! -d "$srcdir" ]; then
    echo 'Source directory does not exist; trying to extract'
    srcfile="$bzipsdir/php-$version.tar.bz2"
    if [ ! -f "$srcfile" ]; then
        echo 'Source file not found:'
        echo "$srcfile"
        #FIXME: use php4 if version is that
        url="http://museum.php.net/php5/php-$version.tar.bz2"
	wget -P "$bzipsdir" "$url"
	if [ ! -f "$srcfile" ]; then
            #FIXME: fetch from museum
	    echo "Fetching source from museum failed:"
	    echo $url
            exit 2
	fi
    fi
    #extract
    tar xjvf "$srcfile"
fi


source 'options.sh' $version
cd "$srcdir"
#configuring
#TODO: do not configure when config.nice exists
./configure \
 --prefix="$instdir" \
 --exec-prefix="$instdir" \
 --program-suffix="-$version" \
 --enable-debug \
 --disable-short-tags \
 --without-pear \
 $configoptions

if [ $? -gt 0 ]; then
    echo configure.sh failed.
    exit 3
fi

#compile sources
#make clean
make

if [ "$?" -gt 0 ]; then
    echo make failed.
    exit 4
fi

#TODO: make install
make install
if [ "$?" -gt 0 ]; then
    echo make install failed.
    exit 5
fi

#create bin
[ ! -d "$shbindir" ] && mkdir "$shbindir"
if [ ! -d "$shbindir" ]; then
    echo "Cannot create shared bin dir"
    exit 6
fi
#symlink all files

#php may be called php-$version.gcno
bphp="$instdir/bin/php-$version"
bphpgcno="$instdir/bin/php-$version.gcno"
if [ -f "$bphp" ]; then 
    ln -s "$bphp" "$shbindir/"
elif [ -f "$bphpgcno" ]; then
    ln -s "$bphpgcno" "$shbindir/php-$version"
else
    echo "no php binary found"
    exit 7    
fi

#php-cgi may be called php-$version.gcno
bphpcgi="$instdir/bin/php-cgi-$version"
bphpcgigcno="$instdir/bin/php-cgi-$version.gcno"
if [ -f "$bphpcgi" ]; then 
    ln -s "$bphpcgi" "$shbindir/"
elif [ -f "$bphpcgigcno" ]; then
    ln -s "$bphpcgigcno" "$shbindir/php-cgi-$version"
else
    echo "no php-cgi binary found"
    exit 8
fi

ln -s "$instdir/bin/php-config-$version" "$shbindir/"
ln -s "$instdir/bin/phpize-$version" "$shbindir/"
