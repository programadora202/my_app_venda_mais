# my_app_venda_mais

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Depuração do app no Chrome

Crie `firebase-web.local.json` na raiz do projeto, com o objeto
`firebaseConfig` do app **Web** no console Firebase, em formato JSON
(apenas o objeto, com chaves e valores entre aspas duplas). O arquivo
fica fora do Git. Use a configuração de um ambiente de teste para cadastrar
usuários, produtos ou vendas de teste.

```powershell
flutter run -d chrome --web-port=7357 --web-browser-flag=--user-data-dir=.chrome-debug-profile --dart-define-from-file=firebase-web.local.json
```

O app usa Firebase Authentication e Cloud Firestore. No Chrome, as fotos
novas ficam no IndexedDB do navegador. Mantenha a porta e o perfil de
depuração do comando para reaproveitar as fotos. Elas não sincronizam
entre dispositivos e podem ser perdidas se os dados do site forem apagados.
