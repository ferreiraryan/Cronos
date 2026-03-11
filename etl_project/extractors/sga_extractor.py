import pdfplumber
import re
from typing import List, Dict, Optional
from models import Lesson

class SGAExtractor:
    """ 
    Extração Determinística do Sistema de Gestão Académica (SGA).
    Foca na tabela "Local das Aulas" para evitar o caos do grid visual.
    """
    def __init__(self, pdf_path: str):
        self.pdf_path = pdf_path
        
        self.day_map = {
            "segunda": 0, "terça": 1, "quarta": 2, 
            "quinta": 3, "sexta": 4, "sábado": 5, "sabado": 5
        }

    def _clean_text(self, text: Optional[str]) -> str:
        if not text:
            return ""
        return re.sub(r'\s+', ' ', text.replace('\n', ' ')).strip()

    def _parse_time(self, time_str: str) -> tuple[str, str]:
        """Converte '08:50 10:30' ou '08:50\n10:30' para ('08:50', '10:30')"""
        times = re.findall(r'\d{2}:\d{2}', time_str)
        if len(times) >= 2:
            return times[0], times[1]
        return "00:00", "00:00"

    def extract_base_schedule(self) -> Dict[int, List[Lesson]]:
        weekly_schedule: Dict[int, List[Lesson]] = {i: [] for i in range(7)}
        
        with pdfplumber.open(self.pdf_path) as pdf:
            for page in pdf.pages:
                text = page.extract_text()
                if not text or "Local das Aulas" not in text:
                    continue
                
                tables = page.extract_tables()
                for table in tables:
                    if not table or len(table) < 2:
                        continue
                        
                    for row in table[1:]:
                        if len(row) < 5 or not row[0]:
                            continue
                            
                        subject_id = self._clean_text(row[0])
                        subject_name = self._clean_text(row[1])
                        day_str = self._clean_text(row[2]).lower()
                        time_raw = row[3] if row[3] else ""
                        location = self._clean_text(row[4])
                        
                        day_int = self.day_map.get(day_str)
                        if day_int is None:
                            continue 
                            
                        time_start, time_end = self._parse_time(time_raw)
                        
                        lesson = Lesson(
                            time_start=time_start,
                            time_end=time_end,
                            subject_id=subject_id,
                            subject_name=subject_name,
                            location=location
                        )
                        weekly_schedule[day_int].append(lesson)
                        
        for day in weekly_schedule:
            weekly_schedule[day].sort(key=lambda x: x.time_start)
            
        return weekly_schedule

if __name__ == "__main__":
    extractor = SGAExtractor("../raw_pdfs/SGA - Grade de Horários.pdf")
    grade = extractor.extract_base_schedule()
    
    for dia, aulas in grade.items():
        if aulas:
            print(f"\n--- Dia {dia} ---")
            for a in aulas:
                print(f"[{a.time_start} - {a.time_end}] {a.subject_name} ({a.location})")
