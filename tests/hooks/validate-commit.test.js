/**
 * Smoke tests for .claude/hooks/validate-commit.sh
 *
 * Tests the input-routing logic (what exits 0 immediately) without
 * requiring a live git repo or staged files.
 *
 * Exit codes:
 *   0 = allowed / pass-through
 *   2 = blocked
 */

const { execSync } = require('child_process');
const path = require('path');

const isWindows = process.platform === 'win32';

// validate-commit.sh is Unix-only; skip on Windows (ps1 mirror path differs)
if (isWindows) {
    console.log('SKIP: validate-commit.test.js — Unix-only hook (bash)');
    process.exit(0);
}

const hookPath = path.join(__dirname, '../../.claude/hooks/validate-commit.sh');

function runHook(command, toolName = 'Bash') {
    const input = { tool_name: toolName, tool_input: { command } };
    try {
        const stdout = execSync(`bash "${hookPath}"`, {
            input: JSON.stringify(input),
            encoding: 'utf8',
            stdio: ['pipe', 'pipe', 'pipe']
        });
        return { status: 0, stdout, stderr: '' };
    } catch (error) {
        return {
            status: error.status,
            stdout: error.stdout || '',
            stderr: error.stderr || ''
        };
    }
}

// ─── Test runner ──────────────────────────────────────────────────────────────

let passed = 0;
let failed = 0;

function test(name, fn) {
    try {
        fn();
        console.log(`  PASS: ${name}`);
        passed++;
    } catch (err) {
        console.error(`  FAIL: ${name}`);
        console.error(`        ${err.message}`);
        failed++;
    }
}

function assertStatus(result, expected, hint = '') {
    if (result.status !== expected) {
        throw new Error(
            `Expected exit ${expected}, got ${result.status}` +
            (hint ? ` | ${hint}` : '') +
            (result.stderr ? `\n        stderr: ${result.stderr.trim()}` : '')
        );
    }
}

// ─── PASS-THROUGH — non-commit commands ──────────────────────────────────────

console.log('\n[pass-through: non-commit commands]');

test('passthrough_non_git_commit_command_exits_0', () => {
    // Hook must exit 0 immediately for non-git-commit commands
    assertStatus(runHook('ls -la'), 0);
});

test('passthrough_git_status_exits_0', () => {
    assertStatus(runHook('git status'), 0);
});

test('passthrough_git_push_exits_0', () => {
    assertStatus(runHook('git push origin main'), 0);
});

test('passthrough_git_add_exits_0', () => {
    assertStatus(runHook('git add .'), 0);
});

// ─── PASS-THROUGH — non-Bash tools ───────────────────────────────────────────

console.log('\n[pass-through: non-Bash tool]');

test('passthrough_non_bash_tool_exits_0', () => {
    // Hook must skip non-Bash tool calls entirely
    assertStatus(runHook('git commit -m "test"', 'Write'), 0);
});

// ─── PASS-THROUGH — git commit with no staged files ──────────────────────────

console.log('\n[pass-through: git commit, no staged files]');

test('passthrough_git_commit_no_staged_exits_0', () => {
    // Running outside of a repo with staged files → git diff --cached returns empty → exit 0
    // This covers the "no staged files" guard inside the hook
    const result = runHook('git commit -m "chore: test"');
    assertStatus(result, 0, 'empty staged list should short-circuit');
});

// ─── SUMMARY ──────────────────────────────────────────────────────────────────

console.log(`\n${'─'.repeat(50)}`);
console.log(`Results: ${passed} passed, ${failed} failed`);

if (failed > 0) {
    process.exit(1);
}
console.log('All validate-commit tests passed!');
