import os
import glob
import re

effort_map = {
    'commit': 1, 'changelog': 1, 'patch-notes': 1, 'bug-report': 1, 'estimate': 1, 'localize': 1,
    'code-review': 2, 'design-review': 2, 'db-review': 2, 'pr-writer': 2, 'hotfix': 2, 
    'frontend-patterns': 2, 'backend-patterns': 2, 'docker-patterns': 2, 'postgres-patterns': 2,
    'sprint-plan': 3, 'scope-check': 3, 'gate-check': 3, 'release-checklist': 3, 'launch-checklist': 3,
    'retrospective': 3, 'tech-debt': 3, 'perf-profile': 3, 'security-audit': 3,
    'nestjs-expert': 3, 'fastapi-pro': 3, 'prisma-expert': 3, 'drizzle-orm-expert': 3,
    'architecture-decision': 4, 'microservices-patterns': 4, 'event-sourcing-architect': 4,
    'kubernetes-architect': 4, 'hybrid-cloud-architect': 4, 'mlops-engineer': 4,
    'react-native-architecture': 4, 'mobile-developer': 4,
    'architecture-decision-records': 5, 'map-systems': 5, 'cloud-architect': 5,
    'database-architect': 5, 'backend-architect': 5
}

when_to_use_map = {
    'code-review': 'Khi cần full architectural + quality review trước khi merge PR',
    'code-review-checklist': 'Quick self-check trước khi commit, không cần full review',
    'architecture-decision': 'Khi cần ra quyết định công nghệ, ghi lại reasoning',
    'architecture-decision-records': 'Khi cần tạo formal ADR document với full context và alternatives'
}

skills_dir = '.claude/skills'

def update_skill(path):
    skill_name = os.path.basename(os.path.dirname(path))
    with open(path, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()

    # match frontmatter
    pattern = r'^---\n(.*?)\n---'
    match = re.search(pattern, content, re.DOTALL)
    if not match:
        return

    frontmatter = match.group(1)
    lines = frontmatter.split('\n')
    
    changed = False
    
    # check effort
    effort = effort_map.get(skill_name, 3) # default 3
    if not any(l.startswith('effort:') for l in lines):
        lines.append(f'effort: {effort}')
        changed = True

    # check when_to_use
    if skill_name in when_to_use_map:
        if not any(l.startswith('when_to_use:') for l in lines):
            wtu = when_to_use_map[skill_name].replace('"', '\\"')
            lines.append(f'when_to_use: "{wtu}"')
            changed = True
            
    if changed:
        new_frontmatter = '---\n' + '\n'.join(lines) + '\n---'
        new_content = content.replace(match.group(0), new_frontmatter)
        with open(path, 'w', encoding='utf-8') as f:
            f.write(new_content)

for skill_folder in os.listdir(skills_dir):
    skill_path = os.path.join(skills_dir, skill_folder, 'SKILL.md')
    if os.path.exists(skill_path):
        update_skill(skill_path)

print("Updated all SKILL.md files")
