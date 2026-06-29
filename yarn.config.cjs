/** @type {import('@yarnpkg/types')} */
const { defineConfig } = require('@yarnpkg/types');
const { basename } = require('path');

/**
 * @typedef {import('@yarnpkg/types').Yarn.Constraints.Yarn} Yarn
 * @typedef {import('@yarnpkg/types').Yarn.Constraints.Workspace} Workspace
 */

const BASE_URL = 'https://github.com/MetaMask/';

/**
 * @param {Workspace} workspace
 * @returns {string}
 */
function getWorkspaceName(workspace) {
  return basename(workspace.ident);
}

/**
 * @param {Workspace} workspace
 * @param {string} field
 * @param {any} [value]
 */
function expectWorkspaceField(workspace, field, value) {
  const fieldValue = workspace.manifest[field];
  if (fieldValue === null) {
    workspace.error(`Missing required field "${field}".`);
    return;
  }
  if (value) {
    workspace.set(field, value);
  }
}

/**
 * @param {Workspace} workspace
 */
function expectWorkspaceDescription(workspace) {
  expectWorkspaceField(workspace, 'description');

  const { description } = workspace.manifest;
  if (typeof description !== 'string') {
    workspace.error(
      `Expected description to be a string, but got ${typeof description}.`,
    );
    return;
  }

  if (description.endsWith('.')) {
    workspace.set('description', description.slice(0, -1));
  }
}

/**
 * @param {Workspace} workspace
 */
function expectYarnPackageManager(workspace) {
  expectWorkspaceField(workspace, 'packageManager');

  const { packageManager } = workspace.manifest;
  if (!packageManager.startsWith('yarn@')) {
    workspace.error(
      `Expected packageManager to start with "yarn@<version>", but got "${packageManager}".`,
    );
  }

  if (!packageManager.includes('sha256')) {
    workspace.error(
      `Expected packageManager to include a sha256 hash, but got "${packageManager}".`,
    );
  }
}

module.exports = defineConfig({
  async constraints({ Yarn }) {
    const workspace = Yarn.workspace();
    const workspaceName = getWorkspaceName(workspace);
    const workspaceRepository = `${BASE_URL}${workspaceName}`;

    expectWorkspaceField(workspace, 'name', `@metamask/${workspaceName}`);
    expectWorkspaceField(workspace, 'version');
    expectWorkspaceField(workspace, 'license');
    expectWorkspaceDescription(workspace);

    workspace.set('homepage', `${workspaceRepository}#readme`);
    workspace.set('bugs.url', `${workspaceRepository}/issues`);
    workspace.set('repository.type', 'git');
    workspace.set('repository.url', `${workspaceRepository}.git`);

    workspace.set('engines.node', '^20 || ^22 || >=24');

    expectYarnPackageManager(workspace);
  },
});
