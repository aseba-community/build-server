#!/bin/sh
set -eu

cat > lftp << EOF
set ssl:verify-certificate false
open mobots.epfl.ch
cd htdocs/data/aseba-build-server
mirror --reverse
EOF

cd debian
for file in `find -name Packages`
do dir=`dirname "$file"`
	dpkg-scanpackages "$dir" > "$file"
	echo "put -O \"debian/$dir\" \"debian/$file\"" >> ../lftp
done
cd ..

for index in `find -name index.html`
do dir=`dirname "$index"`
	latest="$dir/latest.php"
	rm --force "$latest"
	cat > "$index" <<EOF
<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="utf-8">
		<title>$dir</title>
	</head>
	<body>
		<ul>
EOF
	for file in `ls --ignore=index.html -t "$dir"`
	do
		if ! [ -f "$latest" ]
		then
			echo "<? header('Location: $file'); ?>" > $latest
			echo "put -O \"$dir\" \"$latest\"" >> lftp
		fi
		date=`stat --format=%y "$dir/$file" | cut --delimiter=. --fields=1`
		cat >> "$index" <<EOF
			<li>
				$date <a href="$file">$file</a>
			</li>
EOF
	done
	cat >> "$index" <<EOF
		</ul>
	</body>
</html>
EOF
	echo "put -O \"$dir\" \"$index\"" >> lftp
done

lftp < lftp
