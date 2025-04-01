# FetterApp

Gestor de Obras da Fetter Construtora - Aplicativo Web e Mobile

## Características

- PWA (Progressive Web App)
- Versão Android (APK)
- Interface responsiva
- Funcionamento offline
- Sincronização em tempo real
- Autenticação segura

## Tecnologias Utilizadas

- Flutter
- Supabase
- Dart
- HTML/CSS/JavaScript

## Requisitos

- Flutter SDK
- Dart SDK
- Node.js (para desenvolvimento web)
- Conta Supabase

## Configuração do Ambiente

1. Clone o repositório
```bash
git clone [URL_DO_REPOSITÓRIO]
```

2. Instale as dependências
```bash
flutter pub get
```

3. Configure as variáveis de ambiente
- Copie o arquivo `.env.example` para `.env`
- Preencha as variáveis necessárias

4. Execute o projeto
```bash
flutter run
```

## Build

### Web
```bash
flutter build web --release --web-renderer html
```

### Android
```bash
flutter build apk --release
```

## Estrutura do Projeto

```
lib/
  ├── screens/      # Telas do aplicativo
  ├── services/     # Serviços e APIs
  ├── models/       # Modelos de dados
  ├── widgets/      # Widgets reutilizáveis
  ├── theme/        # Configurações de tema
  └── main.dart     # Ponto de entrada
```

## Deploy

### Web
1. Gere a build web
2. Faça upload da pasta `build/web` para o Netlify

### Android
1. Gere o APK
2. Distribua o arquivo `build/app/outputs/flutter-apk/app-release.apk`

## Contribuição

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## Licença

Este projeto é privado e confidencial. Todos os direitos reservados à Fetter Construtora.
