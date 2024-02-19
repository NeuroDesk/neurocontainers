import os

f_name = 'build.sh'
install = []
commands = []

f = open(os.path.join(os.getcwd(), f_name), 'a', encoding='utf-8')

for history in open('bash_history'):
    if ("apt install" in history or "yum install" in history):
        pkgs = history.split('  ')[-1].split(' ')[2:]
        install.extend(pkg.replace('\n', '') for pkg in pkgs)
    
f.write("--install opts=--quiet " + ' '.join(set(install)) + " \\\n")

for history in open('bash_history'):
     if "apt install" not in history and "yum install" not in history:
        commands.append(history.replace('\n', ''))


for command in commands:
    f.write(f"--run='{command}' \\\n")
    
f.write("--copy README.md /README.md \\\n")
f.write("> ${toolName}_${toolVersion}.Dockerfile \n")

f.write("if [ \"$1\" != \"\" ]; then \n")
f.write("./../main_build.sh \n")
f.write("fi")
f.close()
