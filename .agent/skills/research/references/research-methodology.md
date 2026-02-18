# Research Methodology

Always honoring **YAGNI**, **KISS**, and **DRY** principles.
**Be honest, be brutal, straight to the point, and be concise.**

### Phase 1: Scope Definition

First, you will clearly define the research scope by:
- Identifying key terms and concepts to investigate
- Determining the recency requirements (how current must information be)
- Establishing evaluation criteria for sources
- Setting boundaries for the research depth

### Phase 2: Systematic Information Gathering

You will employ a multi-source research strategy:

1. **Search Strategy**:
   - **Gemini Toggle**: Check `$HOME/.claude/.ck.json` (or `~/.claude/.ck.json`) for `skills.research.useGemini` (default: `true`). If `false`, skip Gemini and use WebSearch.
   - **Gemini Model**: Read from `$HOME/.claude/.ck.json`: `gemini.model` (default: `gemini-3-flash-preview`)
   - If `useGemini` is enabled and `gemini` bash command is available, execute `gemini -y -m <gemini.model> "...your search prompt..."` bash command (timeout: 10 minutes) and save the output using `Report:` path from `## Naming` section (including all citations).
   - If `useGemini` is disabled or `gemini` bash command is not available, use `WebSearch` tool.
   - Run multiple `gemini` bash commands or `WebSearch` tools in parallel to search for relevant information.
   - Craft precise search queries with relevant keywords
   - Include terms like "best practices", "2024", "latest", "security", "performance"
   - Search for official documentation, GitHub repositories, and authoritative blogs
   - Prioritize results from recognized authorities (official docs, major tech companies, respected developers)
   - **IMPORTANT:** You are allowed to perform at most **5 researches (max 5 tool calls)**, user might request less than this amount, **strictly respect it**, think carefully based on the task before performing each related research topic.

2. **Deep Content Analysis**:
   - When you found a potential Github repository URL, use `docs-seeker` skill to find read it.
   - Focus on official documentation, API references, and technical specifications
   - Analyze README files from popular GitHub repositories
   - Review changelog and release notes for version-specific information

3. **Video Content Research**:
   - Prioritize content from official channels, recognized experts, and major conferences
   - Focus on practical demonstrations and real-world implementations

4. **Cross-Reference Validation**:
   - Verify information across multiple independent sources
   - Check publication dates to ensure currency
   - Identify consensus vs. controversial approaches
   - Note any conflicting information or debates in the community

### Phase 3: Analysis and Synthesis

You will analyze gathered information by:
- Identifying common patterns and best practices
- Evaluating pros and cons of different approaches
- Assessing maturity and stability of technologies
- Recognizing security implications and performance considerations
- Determining compatibility and integration requirements

### Phase 4: Report Generation

**Notes:**
- Research reports are saved using `Report:` path from `## Naming` section.
- If `## Naming` section is not available, ask main agent to provide the output path.

You will create a comprehensive markdown report with the following structure:

```markdown
# Research Report: [Topic]
