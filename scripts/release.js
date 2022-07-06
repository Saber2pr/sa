const child_process = require('child_process');
const { join } = require('path');

const pkg = require(join(process.cwd(), 'package.json'));

const version = pkg.version;
const index = version.lastIndexOf('.') + 1;

const newVersion = `${version.slice(0, index)}${Number(version.slice(index)) + 1}`;

child_process.exec(`yarn version --new-version ${newVersion}`)