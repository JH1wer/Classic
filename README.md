## simple roblox game
Para poder usar o `rojo serve` é necessário fazer uma build antes
```bash
# se usa rokit:
rokit install

# instalar dependencias
wally install

# build que irá criar o default.project.json
npm run build:rojo

# abrir o servidor rojo
rojo serve
```
para usar o vscode
```bash
# EXECUTE A BUILD

rojo sourcemap -o sourcemap.json

# é necessário o nodejs e npm
npm install # instala o chokidar

# verificar sempre que uma alteração foi feita na estrutura do src e atualizar no default.project.json
npm run watch:rojo

# se os tipos nao aparecer, use o comando
wally-package-types -s sourcemap.json Packages/
wally-package-types -s sourcemap.json ServerPackages/
```