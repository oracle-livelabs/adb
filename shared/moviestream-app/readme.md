# Install application
```
git clone \
  --depth 1  \
  --filter=blob:none  \
  --sparse \
  https://github.com/oracle-livelabs/adb.git \
;
cd adb
git sparse-checkout init --cone
git sparse-checkout set shared/moviestream-app
```

(https://github.com/ashrithamalli/MovieStream.git)

# run locally in the MovieStream project folder
npm install
npm run dev

## Steps
1. 