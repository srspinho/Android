# Neon Butantã: instruções para o Claude

- Converse em português.
- **Sempre que alterar o projeto, suba para o GitHub na branch `main`** (pedido do
  dono do repositório). Antes, rode os testes automáticos das fases.
- Projeto Godot 4.3 (GDScript). Gráficos em `art/`, gerados por `tools/gen_art.py`:
  edite o gerador e rode `python3 tools/gen_art.py` em vez de editar os PNGs à mão.
- Sons em `audio/`, gerados por `tools/gen_audio.py` (precisa de numpy).
- Fases em `levels/` (mapa de caracteres; a legenda está no topo de cada arquivo).
- Testes: `godot --path . res://tests/smoke_test.tscn -- <pasta>` e
  `godot --path . res://tests/smoke_test_fase2.tscn -- <pasta>`.
