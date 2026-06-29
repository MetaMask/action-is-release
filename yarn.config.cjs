/** @type {import('@yarnpkg/types')} */
const { defineConfig } = require('@yarnpkg/types');
const { basename } = require('path');

/**
 * Aliases for the Yarn type definitions, to make the code more readable.
 *
 * @typedef {import('@yarnpkg/types').Yarn.Constraints.Yarn} Yarn
 * @typedef {import('@yarnpkg/types').Yarn.Constraints.Workspace} Workspace
 */

const BASE_URL = 'https://github.com/MetaMask/';

/**
 * Get the name of the workspace. The workspace name is expected to be in the
 * form `@metamask/workspace-name`, and this function will extract
 * `workspace-name`.
 *
 * @param {Workspace} workspace - The workspace.
 * @returns {string} The name of the workspace.
 */
function getWorkspaceName(workspace) {
  return basename(workspace.ident);
}

/**
 * Expect that the workspace has the given field, and that it is a non-null
 * value. If the field is not present, or is null, this will log an error, and
 * cause the constraint to fail.
 *
 * If a value is provided, this will also verify that the field is equal to the
 * given value.
 *
 * @param {Workspace} workspace - The workspace to check.
 * @param {string} field - The field to check.
 * @param {any} [value] - The value to check.
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
 * Expect that the workspace has a description, and that it is a non-null
 * string. If the description is not present, or is null, this will log an
 * error, and cause the constraint to fail.
 *
 * This will also verify that the description does not end with a period.
 *
 * @param {Workspace} workspace - The workspace to check.
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
 * Expect that the workspace has a package manager set, and that it is Yarn with
 * a sha256 hash.
 *
 * @param {Workspace} workspace - The workspace to check.
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
  /**
   * Define the constraints for this project.
   *
   * @param {object} args - The arguments.
   * @param {Yarn} args.Yarn - The Yarn "global".
   */
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
