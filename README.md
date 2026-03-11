# 📚 Extrator de Cronogramas Acadêmicos (MVP)

Este projeto consiste em um **pipeline de dados (ETL)** responsável por transformar PDFs acadêmicos não estruturados (Grade SGA + Cronogramas de Matérias) em um **contrato de dados JSON previsível**, consumido por um aplicativo mobile em Flutter.

---

# 🏗️ Visão Geral da Arquitetura

Pipeline dividido em 4 fases principais:

1. **Data Extraction (Python - ETL)**
2. **Data Contract (JSON Schema Final)**
3. **Client Mobile (Flutter - Client Only)**
4. **Deploy & Workflow (Automação)**

---

# 🔹 Fase 1 — Data Extraction (Python Script)

Script responsável por transformar PDFs não estruturados em um contrato de dados previsível.

## ⚙️ Setup de Ambiente

- Criar ambiente virtual:

```bash
python -m venv venv
```

- Instalar dependências:

```bash
pip install pymupdf pdfplumber google-generativeai pydantic
```

---

# 📋 Tabela de Requisitos (ETL)

## REQ-01 — Ingestão

**Descrição:** O script deve ler múltiplos PDFs de um diretório local `/raw_pdfs`.

**Estratégia Técnica:** Uso de `os` ou `pathlib` para iterar sobre arquivos.

**Prioridade:** Alta

### ✅ Checklist

- ✅ 

---

## REQ-02 — Classificação

**Descrição:** Identificar o tipo de PDF:

- Grade de Horário (SGA)
- Cronograma de Matéria

**Estratégia Técnica:** Checar strings fixas na página 1:

- "Grade de Horários"
- "CRONOGRAMA DE AULAS"

**Prioridade:** Alta

### ✅ Checklist

- ✅ 

---

## REQ-03 — Extração de Tabela (SGA)

**Descrição:** Extrair:

- Horários
- Dias da semana
- Matérias
- Local das aulas

**Estratégia Técnica:** Uso de `pdfplumber.extract_tables()` e mapeamento da matriz para dicionário estruturado.

**Prioridade:** Alta

### ✅ Checklist

- ✅ 

---

## REQ-04 — Extração Heurística (Cronogramas via LLM)

**Descrição:** Transformar texto caótico em pares estruturados:

- Data
- Assunto
- Resumo
- Referências
- Avaliação (boolean)

**Estratégia Técnica:** Enviar texto bruto para API (Gemini/OpenAI) usando Structured Outputs (JSON Schema).

**Prioridade:** Alta

### ✅ Checklist

- ✅ 

---

## REQ-05 — Sanitização de Datas

**Descrição:** Converter datas como:

- "24/02"
- "seg., 23/02"

Para ISO 8601:

```
YYYY-MM-DD
```

**Estratégia Técnica:**

- Injetar ano dinamicamente
- Usar `datetime.strptime`

**Prioridade:** Alta

### ✅ Checklist

- ✅ 

---

## REQ-06 — Merge de Dados

**Descrição:** Cruzar:

- Grade (SGA)
- Cronogramas

Usando `subject_name` como chave.

**Estratégia Técnica:** Lógica de dicionário em Python, injetando `topic` dentro de `lesson`.

**Prioridade:** Média

### ✅ Checklist

- ✅ 

---

## REQ-07 — Exportação

**Descrição:** Gerar `database.json` final consumido pelo Flutter.

**Estratégia Técnica:** Uso de `json.dump(..., indent=2)`.

**Prioridade:** Alta

### ✅ Checklist

- ✅ 

---

# 🔹 Fase 2 — Data Contract (JSON Schema Final)

Estrutura extensível com suporte futuro para:

- Notas
- Faltas
- Customizações do usuário

## 📦 Estrutura Base

```json
{
  "semester": "2026/1",
  "schedule": [
    {
      "date": "2026-03-04",
      "day_of_week": 3,
      "lessons": [
        {
          "time_start": "08:50",
          "time_end": "10:30",
          "subject_id": "6976.1.00",
          "subject_name": "ALGORITMOS E ESTRUTURAS DE DADOS I",
          "location": "Prédio 4 - Ed. Fernanda (1162) | 03º Andar | Sala 302",
          "topic": "Estruturas condicionais",
          "summary": "Introdução aos comandos if, if-else e switch.",
          "references": ["Capítulo 4 - Ascencio"],
          "is_exam": false,
          "metadata": {
            "custom_notes": "",
            "grade": null,
            "absence_count": 0
          }
        }
      ]
    }
  ]
}
```

---

# 🔹 Fase 3 — Client Mobile (Flutter)

Arquitetura focada em componentização e escalabilidade.

## ⚙️ Setup

- Criar projeto Flutter
- Adicionar `database.json` em `/assets`
- Criar models com `freezed` ou `json_serializable`

---

## 📆 View 1 — Timeline (Dia/Semana)

### Componentes

- `ListView` ou `CustomScrollView`
- Linha vertical estilo timeline
- Cards expansíveis

### Funcionalidades

- Indicador de horário atual
- BottomSheet com resumo e referências
- Toggle: Hoje / Semana

### ✅ Checklist

-

---

## 🗓️ View 2 — Grid Mensal

### Componentes

- `TableCalendar` ou grid customizado

### Funcionalidades

- Badge vermelho para `is_exam: true`
- Clique no dia → abre Timeline do dia

### ✅ Checklist

-

---

# 🔹 Fase 4 — Deploy & Workflow

## 🔁 Script de Sincronização

Shell script responsável por:

1. Rodar ETL Python
2. Gerar `database.json`
3. Copiar para projeto Flutter
4. Build do app

### ✅ Checklist

-

---

# 🚀 Status Geral do Projeto

## ETL

-

## Flutter

-

## Deploy

-

---

# 📌 Próximos Passos

- Implementar MVP do ETL
- Validar JSON com mock real
- Criar protótipo visual Flutter
- Automatizar workflow completo

---

**Projeto MVP — Extrator de Cronogramas Acadêmicos**

Arquitetura pensada para ser extensível, previsível e preparada para evoluir para um sistema acadêmico pessoal completo.

