- The git repo is in a subfolder @src/OtterApp/

## Working pattern

- **Never block on a decision when there is other work to do.** When you hit a choice that needs my input, ask it asynchronously (surface the question) and keep implementing other items in parallel — do not stop and wait. Batch questions as they arise; I will answer while you continue. Only hard-block if every remaining task depends on the unanswered decision.
- **Prefer differentiated code over reinvention.** Before hand-rolling a capability, check whether the framework/SDK already provides it out of the box (e.g. Strands session managers, AgentCore Memory, native structured output). Use the built-in unless there is a documented reason not to. Our value is in the differentiated logic, not re-implementing platform primitives.