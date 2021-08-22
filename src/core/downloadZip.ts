import { Stream } from "stream";

const got = require('got');
const unzipper = require('unzipper');

export const downloadZip = async (
  tarballUrl: string,
  projectLocation: string
) => {
  return new Promise(async (resolve, reject) => {
    const stream = await got.stream(tarballUrl) as Stream
    stream.pipe(unzipper.Extract({ path: projectLocation }))
    stream.on('end', resolve)
    stream.on('error', reject)
  })
}
