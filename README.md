# Neon Butantã

Jogo de plataforma e tiro 2D no estilo do clássico **Duke Nukem** (1991), com visual
**cyberpunk** e fases baseadas na região do **Butantã / Rio Pequeno**, em São Paulo.
Feito em **Godot 4** para **Android**, mas também roda no PC.

![Rua](docs/screenshots/rua.png)
![Metrô](docs/screenshots/metro.png)

## O que já funciona (demo da Fase 1 – Estação Butantã)

- Herói (Duca Neon) que anda, pula (com pulo curto/longo), sobe escadas, desce de plataformas e atira
- Inimigos: androide de segurança, drone de vigilância e cobra cibernética
- Itens: coxinha energética (vida), cartão de acesso vermelho, turbo no blaster, chips de dados (pontos)
- Porta de laser que só abre com o cartão, lodo tóxico, trilho energizado
- Fundo com parallax (Torre do Relógio da USP ao longe), chuva e letreiros de neon
- HUD (energia, créditos, itens) e controles de toque na tela
- Todos os gráficos são desenhados por código, então não há imagens para baixar

## Como abrir e jogar no PC

1. Baixe o **Godot 4.3** (versão padrão, não a .NET): https://godotengine.org/download
2. Abra o Godot, clique em **Importar** e escolha o arquivo `project.godot` desta pasta.
3. Aperte **F5** para jogar.

| Ação | Teclado | Controle |
|---|---|---|
| Andar | ← → ou A D | Direcional |
| Subir/descer escada | ↑ ↓ ou W S | Direcional |
| Pular | Espaço, Z ou K | A |
| Atirar | X, J ou Ctrl | X |
| Descer da plataforma | ↓ + Pular | |
| Continuar/reiniciar | Enter ou R | Start |

Para ver os botões de toque no PC, em **Depurar → Personalizar argumentos de execução**
coloque `-- --touch`. O mouse simula o dedo.

## Como gerar o APK para Android

Só é preciso fazer uma vez:

1. Instale o **JDK 17** (por exemplo, o OpenJDK da Adoptium) e o **Android SDK**
   (o jeito mais fácil é instalar o Android Studio).
2. No Godot: **Editor → Configurações do Editor → Exportar → Android**, e informe o
   caminho do Java SDK e do Android SDK.
3. **Editor → Gerenciar Modelos de Exportação → Baixar e Instalar**.

Depois disso:

4. **Projeto → Exportar…** O preset "Android" já está configurado.
5. Clique em **Exportar Projeto** para gerar `build/NeonButanta.apk`.
6. Copie o APK para o celular e instale (é preciso permitir "fontes desconhecidas").

Também dá para ligar o celular no USB com a **Depuração USB** ativa. Aí aparece um
ícone do Android no canto do editor, e um clique instala e roda o jogo direto no aparelho.

## Como criar ou editar fases

As fases ficam em `levels/` e são desenhadas com caracteres, um por bloco de 16×16 px.
A legenda está no topo de `levels/fase1_estacao_butanta.gd`. Para criar uma fase nova:

1. Copie o arquivo da fase 1 e mude `NAME`, `SUBTITLE`, `SIGNS` (letreiros) e `MAP`.
2. Adicione o arquivo na lista `LEVELS` em `scripts/main.gd`.

Dica: o pulo alcança 3 blocos de altura e uns 4 de distância.

## Estrutura

```
project.godot          configuração (resolução 640x360, paisagem, renderizador mobile)
scenes/main.tscn       cena principal
scripts/main.gd        lê o mapa, cria colisões e entidades, controla morte/vitória
scripts/player.gd      herói: movimento, escada, tiro, dano
scripts/enemy_*.gd     inimigos (base + segurança, drone, cobra)
scripts/pickup.gd      itens e saída
scripts/door.gd        porta de laser
scripts/level_art.gd   desenho dos blocos, túnel, escadas e letreiros
scripts/hazard_art.gd  lodo tóxico e trilho energizado animados
scripts/background.gd  céu e prédios com parallax
scripts/rain.gd        chuva
scripts/hud.gd         interface
scripts/touch_controls.gd  botões na tela do celular
levels/                mapas das fases
tests/smoke_test.*     teste automático que joga a fase 1
docs/GDD.md            documento de design (história, fases, inimigos, ideias)
```

## Teste automático

```
godot --path . res://tests/smoke_test.tscn -- /tmp/prints
```

O teste anda, desce a escada do metrô, pega o cartão, abre a porta e chega na saída,
imprime cada etapa e salva prints na pasta indicada.
