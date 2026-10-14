---
name: "create-excalidraw-file"
description: "Create a valid .excalidraw JSON file that a user can import into Excalidraw or a self-hosted Excalidraw instance, without needing MCP."
version: 1
created: "2026-06-01"
updated: "2026-06-01"
---
## When to Use

Use this skill when the user wants an agent to create an Excalidraw diagram as a file that they can open or import manually.

Typical requests:

- "Create an Excalidraw file"
- "Make a .excalidraw diagram on my Desktop"
- "Generate a diagram I can open in my self-hosted Excalidraw"
- "Can agents create Excalidraw files without MCP?"
- "Write a simple .excalidraw file so I can test import"

Use this skill for file-based workflow only:

1. Agent writes a `.excalidraw` JSON file.
2. User opens their Excalidraw app or self-hosted Excalidraw URL.
3. User imports/opens the file manually.

Do not require MCP for this workflow. MCP is only needed for live tool integration, embedded canvas workflows, or server-assisted UI/export flows.

## Core Rule

A `.excalidraw` file is JSON. The agent can create it directly with the normal file-write tool.

Minimum top-level shape:

```json
{
  "type": "excalidraw",
  "version": 2,
  "source": "agent",
  "elements": [],
  "appState": {},
  "files": {}
}
```

If the user has self-hosted Excalidraw at a URL such as `http://192.168.1.112:5000/`, do not try to upload to that URL unless the user explicitly asks for browser automation or server integration. Instead, create the file and tell the user to import/open it in that app.

## Procedure

### 1. Confirm file workflow, not MCP workflow

If the user asks whether MCP is needed, answer:

- No MCP needed for `.excalidraw` file creation.
- Agent can write `.excalidraw` JSON to disk.
- User imports/opens the file in Excalidraw/self-hosted Excalidraw.

Only discuss MCP if user asks for:

- live canvas inside an MCP-capable client;
- automatic share/export through Excalidraw servers;
- agent editing existing Excalidraw session interactively;
- tool-call integration with Excalidraw MCP.

### 2. Choose output path

If user gives a path, use it exactly.

If user says "Desktop", use the current user's Desktop path. Common examples:

- macOS: `/Users/<username>/Desktop/name.excalidraw`
- Linux: `/home/<username>/Desktop/name.excalidraw`
- Windows paths depend on tool environment; ask if unclear.

If current working directory is `/Users/vvbz`, Desktop path is usually:

```text
/Users/vvbz/Desktop/name.excalidraw
```

Use file extension `.excalidraw`.

### 3. Build valid Excalidraw JSON

Always include:

```json
{
  "type": "excalidraw",
  "version": 2,
  "source": "agent-created",
  "elements": [
    ...
  ],
  "appState": {
    "viewBackgroundColor": "#ffffff",
    "gridSize": null
  },
  "files": {}
}
```

Use `elements` array for diagram objects. Common element types:

- `rectangle`
- `ellipse`
- `diamond`
- `arrow`
- `line`
- `text`

Each element should include enough fields for broad Excalidraw compatibility.

Required/common fields for shape elements:

```json
{
  "id": "unique-id",
  "type": "rectangle",
  "x": 100,
  "y": 100,
  "width": 200,
  "height": 100,
  "angle": 0,
  "strokeColor": "#1e1e1e",
  "backgroundColor": "#d0ebff",
  "fillStyle": "solid",
  "strokeWidth": 2,
  "strokeStyle": "solid",
  "roughness": 1,
  "opacity": 100,
  "groupIds": [],
  "frameId": null,
  "roundness": { "type": 3 },
  "seed": 123456,
  "version": 1,
  "versionNonce": 111111,
  "isDeleted": false,
  "boundElements": null,
  "updated": 1,
  "link": null,
  "locked": false
}
```

Required/common fields for text elements:

```json
{
  "id": "text-1",
  "type": "text",
  "x": 130,
  "y": 135,
  "width": 140,
  "height": 25,
  "angle": 0,
  "strokeColor": "#1e1e1e",
  "backgroundColor": "transparent",
  "fillStyle": "solid",
  "strokeWidth": 1,
  "strokeStyle": "solid",
  "roughness": 1,
  "opacity": 100,
  "groupIds": [],
  "frameId": null,
  "roundness": null,
  "seed": 123457,
  "version": 1,
  "versionNonce": 222222,
  "isDeleted": false,
  "boundElements": null,
  "updated": 1,
  "link": null,
  "locked": false,
  "text": "Hello Excalidraw",
  "fontSize": 20,
  "fontFamily": 1,
  "textAlign": "center",
  "verticalAlign": "middle",
  "containerId": null,
  "originalText": "Hello Excalidraw",
  "lineHeight": 1.25
}
```

Required/common fields for arrow elements:

```json
{
  "id": "arrow-1",
  "type": "arrow",
  "x": 320,
  "y": 150,
  "width": 80,
  "height": 0,
  "angle": 0,
  "strokeColor": "#1e1e1e",
  "backgroundColor": "transparent",
  "fillStyle": "solid",
  "strokeWidth": 2,
  "strokeStyle": "solid",
  "roughness": 1,
  "opacity": 100,
  "groupIds": [],
  "frameId": null,
  "roundness": { "type": 2 },
  "seed": 123458,
  "version": 1,
  "versionNonce": 333333,
  "isDeleted": false,
  "boundElements": null,
  "updated": 1,
  "link": null,
  "locked": false,
  "points": [[0, 0], [80, 0]],
  "lastCommittedPoint": null,
  "startBinding": null,
  "endBinding": null,
  "startArrowhead": null,
  "endArrowhead": "arrow"
}
```

### 4. Use unique IDs

Every element needs a unique `id` string.

Simple safe pattern:

- `box-1`
- `text-1`
- `arrow-1`
- `box-2`
- `text-2`

Avoid duplicate IDs. Duplicate IDs can make import weird or corrupt edits.

### 5. Keep coordinates simple

Use positive `x` and `y` values so imported diagram appears in visible area.

Good starting layout:

- First box: `x: 100`, `y: 100`
- Second box: `x: 400`, `y: 100`
- Arrow between boxes: `x: 320`, `y: 150`, `points: [[0,0],[80,0]]`

Avoid huge coordinates like `x: 10000` unless user asks.

### 6. Write the file

Use the agent's file-write tool, not shell redirection, unless no file-write tool exists.

Write pretty JSON with 2-space indentation. This helps humans inspect file if import fails.

### 7. Validate JSON after writing

If a shell is available, validate with one of these:

```bash
python3 -m json.tool /path/to/file.excalidraw >/dev/null
```

or:

```bash
node -e "JSON.parse(require('fs').readFileSync('/path/to/file.excalidraw','utf8')); console.log('valid json')"
```

If validation fails, fix JSON before replying.

### 8. Final reply

Tell user exact file path and one instruction:

```text
File created: /path/to/file.excalidraw
Open Excalidraw/self-hosted Excalidraw, then import/open this file.
```

Keep reply short. Do not claim automatic integration unless you actually implemented it.

## Full Simple Example

Write this to `simple-agent-test.excalidraw` when user wants a minimal test file:

```json
{
  "type": "excalidraw",
  "version": 2,
  "source": "agent-created-test",
  "elements": [
    {
      "id": "box-1",
      "type": "rectangle",
      "x": 120,
      "y": 120,
      "width": 220,
      "height": 100,
      "angle": 0,
      "strokeColor": "#1e1e1e",
      "backgroundColor": "#d0ebff",
      "fillStyle": "solid",
      "strokeWidth": 2,
      "strokeStyle": "solid",
      "roughness": 1,
      "opacity": 100,
      "groupIds": [],
      "frameId": null,
      "roundness": { "type": 3 },
      "seed": 123456,
      "version": 1,
      "versionNonce": 111111,
      "isDeleted": false,
      "boundElements": null,
      "updated": 1,
      "link": null,
      "locked": false
    },
    {
      "id": "text-1",
      "type": "text",
      "x": 160,
      "y": 155,
      "width": 140,
      "height": 25,
      "angle": 0,
      "strokeColor": "#1e1e1e",
      "backgroundColor": "transparent",
      "fillStyle": "solid",
      "strokeWidth": 1,
      "strokeStyle": "solid",
      "roughness": 1,
      "opacity": 100,
      "groupIds": [],
      "frameId": null,
      "roundness": null,
      "seed": 123457,
      "version": 1,
      "versionNonce": 222222,
      "isDeleted": false,
      "boundElements": null,
      "updated": 1,
      "link": null,
      "locked": false,
      "text": "Agent made this",
      "fontSize": 20,
      "fontFamily": 1,
      "textAlign": "center",
      "verticalAlign": "middle",
      "containerId": null,
      "originalText": "Agent made this",
      "lineHeight": 1.25
    }
  ],
  "appState": {
    "viewBackgroundColor": "#ffffff",
    "gridSize": null
  },
  "files": {}
}
```

## Self-hosted Excalidraw Notes

For self-hosted Excalidraw at `http://192.168.1.112:5000/` or similar:

- File import/open should work if the self-hosted build includes normal Excalidraw import support.
- The agent does not need to know the server internals for file creation.
- The file stays local until user imports it.
- Do not use `https://excalidraw.com/#json=...` unless user wants official hosted Excalidraw sharing.
- Do not upload private diagrams to `json.excalidraw.com` unless user explicitly asks.

## Pitfalls

- Do not create a file named `.json` when user asked for `.excalidraw`.
- Do not output only a code block if user asked to place file on Desktop; actually write the file.
- Do not require `excalidraw-mcp` for local file creation.
- Do not assume self-hosted Excalidraw accepts remote `#json=` links like official `excalidraw.com`.
- Do not upload diagram data to any public server unless user explicitly asks.
- Do not omit `files`: use empty object `{}` if there are no embedded images.
- Do not omit `appState`: use at least `viewBackgroundColor` and `gridSize`.
- Do not duplicate element IDs.
- Do not use comments inside JSON. JSON with comments is invalid.
- Do not leave trailing commas. Excalidraw import expects valid JSON.
- Do not use negative or huge coordinates for simple diagrams; user may think import failed because content is off-screen.

## Verification

Before final reply, verify all of these:

1. File path ends with `.excalidraw`.
2. File exists at requested location.
3. File contains valid JSON.
4. Top-level `type` is `"excalidraw"`.
5. Top-level `elements` is an array.
6. Top-level `appState` exists.
7. Top-level `files` exists.
8. Every element has a unique `id`.
9. Text elements include `text`, `originalText`, `fontSize`, `fontFamily`, and `lineHeight`.
10. Arrow/line elements include `points`.

If any check fails, fix file before telling user it is ready.