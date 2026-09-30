# Receitas da Anna 🍰

App Flutter para guardar receitas (bolos, salgados, qualquer receita), com visual Dark Premium.

## Funcionalidades

- Criar, editar e excluir receitas (com foto, categoria, dificuldade, tempo, porções, ingredientes e modo de preparo)
- Pesquisa por nome ou ingrediente (ignora acentos), buscas recentes e sugestões
- Categorias e favoritos
- **Compartilhar por código**: gera um código `RDA1-...` que outra pessoa cola em **+ → Adicionar por código**
- Tema escuro/claro e cor de destaque configuráveis
- **Buscar atualização** (Perfil): verifica se há versão nova nas Releases deste repositório

## Rodar

```
flutter pub get
flutter run
```

## Publicar uma nova versão

1. Aumente a versão em `pubspec.yaml` (ex: `version: 1.0.1+2`)
2. Faça commit das mudanças
3. Rode:

```
powershell -ExecutionPolicy Bypass -File scripts\release.ps1 -Notes "O que mudou nesta versão"
```

O script gera o APK, faz `git push` e cria a Release `v1.0.1` com o APK anexado.
No celular, **Perfil → Buscar atualização** encontra a versão nova e baixa o APK.

> O APK é assinado com a chave de debug deste computador. Publique sempre do mesmo
> computador, senão o Android não deixa instalar por cima da versão anterior.

## Estrutura

```
lib/
  theme/      cores (AppColors), espaçamentos, raios, tipografia e ThemeData
  models/     Recipe, categorias e dificuldade
  providers/  receitas, tema e dados do usuário (salvos no aparelho)
  services/   compartilhamento por código e verificação de atualização
  widgets/    componentes reutilizáveis
  screens/    telas
```
