# move to the project directory
cd Projects/website

# initiate the upstream tracking of the project on the GitHub repo
git remote remove origin
git remote add origin https://github.com/johnabrooks/Project2

# Rebase as necessary
git config pull.rebase true

# pull all files from the GitHub repo (typically just readme, license, gitignore)
git pull origin main

# set up GitHub repo to track changes on local machine
git push -u origin main