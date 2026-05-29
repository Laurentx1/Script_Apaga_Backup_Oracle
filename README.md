#  cleanup_backup.sh

Script de limpeza automática de backups **Oracle Datapump**, mantendo sempre os `N` backups mais recentes e removendo os mais antigos com log detalhado.

---

##  Visão Geral

| Item | Detalhe |
|---|---|
| **Banco** | Oracle Database (CDBAGROS) |
| **Tipo de backup** | Oracle Datapump (`.tar.gz`) |
| **Frequência do backup** | A cada 2 dias |
| **Retenção** | 3 backups mais recentes (~6 dias) |
| **Log** | `/u01/backup/datapump/cleanup_backup.log` |

---

##  Estrutura de Diretórios

```
/u01/backup/datapump/backup_datapump_CDBAGROS_SIAGRI/CDBAGROS/
├── 2026-05-28-22-00-01/
│   └── backup_datapump_CDBAGROS_SIAGRI_20260528-220001.tar.gz
├── 2026-05-30-22-00-01/
│   └── backup_datapump_CDBAGROS_SIAGRI_20260530-220001.tar.gz
└── 2026-06-01-22-00-01/
    └── backup_datapump_CDBAGROS_SIAGRI_20260601-220001.tar.gz
```

---

## ⚙️ Configuração

No início do script, ajuste as variáveis conforme necessário:

```bash
BACKUP_DIR="/u01/backup/datapump/backup_datapump_CDBAGROS_SIAGRI/CDBAGROS"
MANTER=3       # Quantidade de backups a manter
LOG="/u01/backup/datapump/cleanup_backup.log"
```

---

##  Instalação

**1. Copiar o script para o servidor:**
```bash
cp cleanup_backup.sh /u01/backup/cleanup_backup.sh
```

**2. Dar permissão de execução:**
```bash
chmod +x /u01/backup/cleanup_backup.sh
```

**3. Testar manualmente:**

Obs.: Melhor testar após ter pelo menos 4 backups (boas práticas)

```bash
/u01/backup/cleanup_backup.sh
```

**4. Verificar o log:**
```bash
cat /u01/backup/datapump/cleanup_backup.log
```

---

##  Agendamento (Cron)

O script é agendado para rodar todo dia às **23h30**, após o backup das 22h:

```bash
crontab -e
```

Adicione a linha:
```
30 23 * * * /u01/backup/cleanup_backup.sh
```

---

##  Lógica de Proteção

O script **nunca deleta** se o total de backups for menor ou igual ao limite configurado:

| Backups encontrados | Ação |
|---|---|
| 1 backup | Nada deletado  |
| 2 backups | Nada deletado  |
| 3 backups | Nada deletado  |
| 4 backups | Deleta o mais antigo  |
| 5 backups | Deleta os 2 mais antigos  |

---

##  Exemplo de Log

```
============================================
Início: 2026-05-29 23:30:01
Diretório: /u01/backup/datapump/backup_datapump_CDBAGROS_SIAGRI/CDBAGROS
Mantendo os 3 backups mais recentes
============================================

--- Backups existentes ---
  /u01/backup/.../2026-05-28-22-00-01  [2,8G]
  /u01/backup/.../2026-05-26-22-00-01  [2,7G]
  /u01/backup/.../2026-05-24-22-00-01  [2,7G]
  /u01/backup/.../2026-05-22-22-00-01  [2,6G]

--- Backups deletados ---
  Deletando: .../2026-05-22-22-00-01  [2,6G]

--- Backups mantidos ---
  .../2026-05-28-22-00-01  [2,8G]
  .../2026-05-26-22-00-01  [2,7G]
  .../2026-05-24-22-00-01  [2,7G]

Limpeza concluída em: 2026-05-29 23:30:02
============================================
```

---

##  Requisitos

- Oracle Linux 8+
- Usuário com permissão de leitura e escrita no diretório de backup
- `bash` 4+

---

## Talles Gomes

Infraestrutura — AGROSANTA PROD
