# Servidor do Endrick — CS 1.6 (Railway + AMX Mod X + ngrok TCP)

Este repositório é um template para rodar um servidor Counter‑Strike 1.6 no Railway usando **SteamCMD** para instalar o HLDS, com **AMX Mod X** e **ngrok (TCP)** para expor a porta do servidor.

> Atenção: Railway pode não expor portas UDP diretamente. Este template usa **ngrok TCP** para que você consiga conectar pelo cliente CS 1.6.

## Como usar

1. Baixe o arquivo ZIP e extraia os arquivos.
2. Crie um repositório no GitHub e faça push dos arquivos ou envie manualmente.
3. No Railway, escolha **New Project → Deploy from GitHub** e selecione o repositório.
4. Defina as variáveis de ambiente no Railway (Settings → Variables):
   - `SERVER_NAME` (ex: Servidor do Endrick)
   - `MAP` (ex: de_dust2)
   - `MAXPLAYERS` (ex: 12)
   - `PORT` (ex: 27015)
   - `NGROK_AUTHTOKEN` (seu token do ngrok — https://dashboard.ngrok.com/get-started/your-authtoken)
   - `STEAM_ACCOUNT` (opcional; padrão: anonymous)

5. Deploy e verifique os logs. O ngrok vai iniciar e você verá a informação do túnel TCP (ex: `0.tcp.ngrok.io:17890`).
6. No CS 1.6, conecte:
   ```
   connect 0.tcp.ngrok.io:17890
   ```

## Observações importantes

- **Autenticação ngrok**: é necessário definir `NGROK_AUTHTOKEN` nas variáveis de ambiente.
- **Limitações**: Railway não é uma solução ideal para servidores de jogo com tráfego UDP em produção. Use VPS (DigitalOcean, AWS Lightsail, Oracle Cloud) para um servidor público com melhor performance.
- **Segurança**: altere `rcon_password` no `server.cfg` antes de abrir para público.
- **AMX Mod X**: plugins básicos já são referenciados em `amxx_plugins/plugins.ini`. Adicione os binários dos plugins na pasta `amxx_plugins` se desejar.

Se quiser, eu posso gerar instruções passo-a-passo para subir no GitHub e conectar no Railway.
