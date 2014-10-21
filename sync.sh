timeStamp=$(date +"%a, %D %r")

if [ ! -d "code" ]; then
git clone $REPO code
fi

cd code
ant -v retrieve;

#Commit changes
git add *
git commit -m "Automated Sync - $timeStamp"
#Push them up to the repo
git push -u origin master