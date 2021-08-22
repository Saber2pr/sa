# @saber2pr/cli

> cli,

```bash
# from npm
npm install @saber2pr/cli

# from github
git clone ___
```

---

## start

```bash
# install the typescript and webpack
npm install
```

```bash
# auto compile to commonjs
npm start

# auto compile to es5
npm run dev

```

> Author: saber2pr

---

## develope and test

> you should write ts in /src

> ts -(tsc)-> commonjs -(webpack)-> es5

> you should make test in /src/test

> export your core in /src/index.ts!

---

## publish

> Before publish, there are some items in package.json should to be updated below:

1. name
2. version
3. description
4. repository(url)
5. author

```bash
# if all is well, try:
npm publish
```

