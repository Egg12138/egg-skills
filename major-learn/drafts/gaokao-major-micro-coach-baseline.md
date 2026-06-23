## Baseline scenarios without a dedicated skill

These scenarios capture where a general assistant is likely to drift when asked to do "major micro-experience coaching" without explicit process guidance.

### Scenario 1: "我想了解物理学"

Likely failure modes:
- Opens with interest, career, city, or parent questions instead of starting the experience immediately.
- Gives a long major introduction, employment summary, or school advice before any task.
- Explains too much and delays contact with a concrete phenomenon.

### Scenario 2: "我想了解法学，时间只有 15 分钟"

Likely failure modes:
- Ignores the requested shorter duration and runs a full teaching sequence.
- Uses open-ended prompts like "你怎么看" instead of scaffolded micro-questions.
- Continues beyond five rounds and turns the session into tutoring or science-pop.

### Scenario 3: "我不会，你直接讲吧"

Likely failure modes:
- Stops the experience because the student cannot answer.
- Corrects too harshly or gives the full answer at once.
- Fails to lower difficulty to a binary choice or smaller sub-step.

### Scenario 4: report generation after the interaction

Likely failure modes:
- Writes a generic summary instead of the required fixed report sections.
- Omits "该专业常见基础课程".
- Lists courses without linking each course back to a thinking step from the micro-experience.

## Design targets for the skill

The skill should force:
- Immediate start with a default 30-minute micro-experience.
- A fixed six-stage flow with no skipped stage.
- At most five rounds of interaction.
- Structured feedback after each student answer.
- A fixed final report with course-to-thinking-step links.

## Iteration 2 gaps

Even after the first draft, two likely drift points remain:

### Gap A: language drift

Likely failure modes:
- The agent reads the English scaffolding terms and responds in mixed Chinese-English.
- The agent keeps English labels such as "Overview" or "Constraints" in its own working output.
- The tone becomes less natural for a Chinese-speaking student because the execution guide is not Chinese-first.

### Gap B: no ready-made examples

Likely failure modes:
- The agent understands the flow but spends too long inventing a first experience from scratch.
- The agent falls back to generic major introductions because it lacks a short reusable starting pattern.
- Different majors get uneven quality because there are no anchor examples for comparison.

### Iteration 2 targets

The next revision should:
- Make the execution guidance Chinese-first.
- Keep the triggering metadata in English, but keep the body mostly in Chinese.
- Add 2-3 reusable example openings that can be adapted directly.

## Iteration 3 gap

### Gap C: choice questions are asked as plain text

Likely failure modes:
- The agent writes `A/B/C/D` options directly in chat instead of using a structured question tool.
- The student interaction becomes noisy because the agent has to parse free-form replies to fixed choices.
- Even when a tool like `AskUserQuestion` exists, the agent ignores it and falls back to plain text out of habit.

### Iteration 3 target

The next revision should:
- Make `AskUserQuestion Tool` mandatory for all choice-based interactions.
- Allow plain-text fallback only when the current environment truly does not provide such a tool.

## Iteration 4 gap

### Gap D: micro-experience drifts from major learning into mature job scenes

Likely failure modes:
- The agent picks a professional workplace scene that reflects the occupation, but not the major's foundational course structure.
- The student mistakes one slice of professional reasoning for the whole major.
- The report later adds course names, but the experience itself still feels like "this major studies this one workplace task every day."

### Iteration 4 target

The next revision should:
- Force the experience slice to map back to undergraduate foundational coursework.
- Prefer foundational learning objects over mature workplace decisions for majors like medicine, law, education, architecture, and journalism.
- Make the report explicitly state that the experience is only one learning slice, not the whole major.
- Keep `【该专业真实困难】` focused on study/training difficulties unless the user explicitly asks for career reality.

## Iteration 5 gap

### Gap E: terminology appears before it is translated

Likely failure modes:
- The agent introduces terms like `左心室肥厚`, `肺淤血`, `鉴别诊断`, `病理过程` directly, assuming the student can absorb them on the fly.
- The agent does explain eventually, but too late; the student is already cognitively blocked by the label.
- Option labels become harder than the reasoning step itself because the wording is packed with unglossed jargon.

### Iteration 5 target

The next revision should:
- Require immediate plain-language glosses for technical terms.
- Prefer simple everyday wording first, with the technical term in parentheses if needed.
- Keep the difficulty in the thinking step, not in decoding vocabulary.

## Iteration 6 gap

### Gap F: the student sees the thinking style, but not the daily training actions

Likely failure modes:
- The experience shows how the discipline thinks, but not what the student actually spends time doing in class and after class.
- The final report names courses, but still leaves the student unable to picture daily workload.
- The output sounds like "this major is about X way of thinking" instead of "students in this major repeatedly do these concrete things."

### Iteration 6 target

The next revision should:
- Force the skill to name 3-5 concrete recurring student tasks.
- Keep these tasks tied to foundational coursework, not generic career scenes.
- Make the report explicitly answer: "这个专业的学生平时具体在做什么？"

## Iteration 7 gap

### Gap G: "real difficulty" drifts into fear framing

Likely failure modes:
- The report overstates difficulty in a way that feels like warning the student away.
- The text emphasizes pressure and sacrifice more than the discipline's actual training texture.
- The student leaves with a strong fear impression but still cannot say what makes the subject distinctive.

### Iteration 7 target

The next revision should:
- Reframe difficulty as common undergraduate learning friction, not horror-story pressure.
- Add an explicit subject-feature section so the report highlights what is distinctive about the discipline.
- Keep the tone honest but non-sensational.
