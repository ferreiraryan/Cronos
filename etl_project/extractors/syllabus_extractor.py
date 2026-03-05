import fitz  # type: ignore
import json
from typing import List, Dict, Any
from pydantic import BaseModel, Field
from google.genai import types

class ExtractedLesson(BaseModel):
    date: str = Field(description="Data da aula no formato YYYY-MM-DD. O ano atual é 2026.")
    topic: str = Field(description="Título principal ou assunto da aula.")
    summary: str = Field(description="Resumo do que será ensinado baseado no texto.")
    references: List[str] = Field(description="Capítulos de livros ou referências bibliográficas da aula.")
    is_exam: bool = Field(description="True se a aula for uma prova, reavaliação ou exame.")

class SyllabusExtraction(BaseModel):
    lessons: List[ExtractedLesson]

class SyllabusExtractor:
    def __init__(self, pdf_path: str, gemini_client):
        self.pdf_path = pdf_path
        self.gemini_client = gemini_client

    def _extract_raw_text(self) -> str:
        # Silencia warnings de metadados malformados no PDF (FontBBox error)
        fitz.TOOLS.mupdf_display_errors(False)  # type: ignore
        text = ""
        try:
            with fitz.open(self.pdf_path) as doc:  # type: ignore
                for page in doc:
                    text += page.get_text("text") + "\n"
        except Exception as e:
            print(f"[!] Erro ao ler {self.pdf_path}: {e}")
        return text

    def extract_topics(self) -> List[Dict[str, Any]]:
        raw_text = self._extract_raw_text()
        if not raw_text.strip():
            return []

        prompt = f"""
        Você é um parser de dados focado em extrair informações de planos de ensino universitários.
        Analise o texto extraído do PDF abaixo e identifique o cronograma de aulas.
        
        Regras:
        1. Formate todas as datas para YYYY-MM-DD (assuma o ano de 2026 para as aulas).
        2. Se não houver referências ou resumos descritivos para um dia específico, infira a partir do título ou deixe em branco.
        3. Identifique avaliações, provas ou exames setando is_exam para true.
        4. Ignore informações irrelevantes como o cabeçalho da universidade ou regras de aprovação. Foque APENAS nos dias de aula.

        Texto bruto extraído do PDF:
        ---
        {raw_text[:25000]}
        ---
        """

        try:
            response = self.gemini_client.models.generate_content(
                model='gemini-2.5-flash',
                contents=prompt,
                config=types.GenerateContentConfig(
                    response_mime_type="application/json",
                    response_schema=SyllabusExtraction,
                )
            )
            
            data = json.loads(response.text)
            return data.get("lessons", [])
            
        except Exception as e:
            print(f"[!] Falha na extração LLM para {self.pdf_path}: {e}")
            return []
