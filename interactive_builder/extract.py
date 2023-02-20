import os

f_name = 'build.sh'
install = []
commands = set()

f = open(os.path.join(os.getcwd(), f_name), 'w', encoding='utf-8')
f.write("#!/usr/bin/env bash\nset -e\nexport toolName=''\nexport toolVersion=''\n")
f.write("if [ \"$1\" != \"\" ]; then\necho \"Entering Debug mode\"\nexport debug=$1\nfi\n")
f.write("source ../main_setup.sh\n")
f.write("neurodocker generate ${neurodocker_buildMode} \\\n")

for history in open('./bash_history'):
    if "apt" in history and "install" in history:
        pkgs = history.split('  ')[-1].split(' ')[2:]
        install.extend(pkg.replace('\n', '') for pkg in pkgs)
    
f.write("--pkg-manager apt" + ' '.join(set(install)) + " \\\n")

for history in open('./bash_history'):
    commands.add(history.split('  ')[-1].replace('\n', ''))
for command in commands:
    f.write(f"--run='{command}' \\\n")
    
f.write("--env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/bin/  \\\n")
f.write("--env DEPLOY_BINS= \\\n")
f.write("--env PATH= \\\n")
f.write("--copy README.md /README.md \\\n")
f.write("> ${toolName}_${toolVersion}.Dockerfile \n")

f.write("if [ \"$1\" != "" ]; then \n")
f.write("./../main_build.sh \n")
f.write("fi")
f.close()
