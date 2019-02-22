rm -rfv _book	
rm -rfv docs
gitbook build
mv _book docs
git add .
git commit -m 'commit'  
git push
