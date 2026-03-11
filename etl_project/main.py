import os
from google import genai

from models import SemesterSchedule
from extractors.sga_extractor import SGAExtractor
from extractors.syllabus_extractor import SyllabusExtractor
from core.merger import ScheduleMerger

# ==========================================
# CONFIGURAÇÃO DE MAPEAMENTO
# ==========================================
FILE_TO_SUBJECT = {
    "2026_1 Crono AEDS1 PL": "ALGORITMOS E ESTRUTURAS DE DADOS I",
    "Cronograma Calc I 1 26 turma 1": "CÁLCULO I",
    "plano_de_disciplina": "MATEMÁTICA DISCRETA E COMPUTABILIDADE",
}

def main():
    print("[*] Iniciando Pipeline ETL de Cronogramas...")
    
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        print("[!] GEMINI_API_KEY não encontrada nas variáveis de ambiente.")
        return
        
    gemini_client = genai.Client(api_key=api_key)
    
    sga_path = "raw_pdfs/SGA - Grade de Horários.pdf"
    if not os.path.exists(sga_path):
        print(f"[!] Grade SGA não encontrada em: {sga_path}")
        return
        
    sga = SGAExtractor(sga_path)
    base_schedule = sga.extract_base_schedule()
    print(f"[+] Grade SGA extraída.")
    
    syllabus_data = {}
    cronogramas_dir = "raw_pdfs/cronogramas"
    
    if os.path.exists(cronogramas_dir):
        for pdf_file in os.listdir(cronogramas_dir):
            if not pdf_file.endswith(".pdf"):
                continue
                
            pdf_path = os.path.join(cronogramas_dir, pdf_file)
            pdf_name = pdf_file.replace(".pdf", "")
            
            nome_materia_sga = FILE_TO_SUBJECT.get(pdf_name)
            
            if not nome_materia_sga:
                print(f"[!] Aviso: '{pdf_name}.pdf' não está no FILE_TO_SUBJECT. O merge pode falhar para esta matéria.")
                nome_materia_sga = pdf_name.upper()
                
            print(f"[*] Processando via LLM: {pdf_file} -> Mapeado para: {nome_materia_sga}")
            
            extractor = SyllabusExtractor(pdf_path, gemini_client)
            syllabus_data[nome_materia_sga] = extractor.extract_topics()
    else:
        print(f"[!] Diretório '{cronogramas_dir}' não encontrado.")
    
    print("[*] Realizando merge dos dados...")
    merger = ScheduleMerger(base_schedule, syllabus_data)
    final_schedule = merger.merge()
    
    output_path = "database.json"
    with open(output_path, "w", encoding="utf-8") as f:
        f.write(final_schedule.model_dump_json(indent=2))
        
    print(f"[+] {output_path} gerado com sucesso. Verifique o arquivo JSON.")

if __name__ == "__main__":
    main()
