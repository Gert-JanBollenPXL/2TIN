import { exec as execCb } from "node:child_process";
import { promisify } from "node:util";

const exec = promisify(execCb);

// run command
const runCmd = async (cmd) => {
    const { error, stdout, stderr } = await exec(cmd);
        if (error || stderr) {
            console.error(err);
            return;
        }
        return JSON.parse(stdout);
}

export default runCmd;