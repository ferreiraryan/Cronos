from typing import List, Dict, Any
from datetime import datetime, timedelta
from models import Lesson, SemesterSchedule, DaySchedule

class ScheduleMerger:
    """
    Cruza a grade fixa do SGA (template semanal) com os cronogramas dinâmicos gerados pelo LLM.
    Atua como um validador: o SGA define "quando" e "onde", o LLM apenas preenche o "o quê".
    """
    def __init__(self, weekly_schedule: Dict[int, List[Lesson]], syllabus_data: Dict[str, List[Dict[str, Any]]]):
        # weekly_schedule: { 0: [Lesson(AEDs), Lesson(Calc)], 1: [...] } -> 0=Segunda, 1=Terça
        # syllabus_data: { "CÁLCULO I": [{"date": "2026-02-24", "topic": "Limites", ...}] }
        self.weekly_schedule = weekly_schedule
        self.syllabus_data = syllabus_data

    def merge(self) -> SemesterSchedule:
        # 1. Coletar todas as datas extraídas pelo LLM para definir o range do semestre
        all_dates = set()
        for subject_classes in self.syllabus_data.values():
            for cls in subject_classes:
                if "date" in cls:
                    all_dates.add(cls["date"])
        
        if not all_dates:
            return SemesterSchedule(semester="Unknown", schedule=[])

        # Converter para objetos datetime para extrair min/max
        date_objs = [datetime.strptime(d, "%Y-%m-%d") for d in all_dates]
        start_date = min(date_objs)
        end_date = max(date_objs)
        
        schedule_days = []
        current_date = start_date

        # 2. Iterar dia a dia garantindo uma timeline contínua (sem buracos)
        while current_date <= end_date:
            date_str = current_date.strftime("%Y-%m-%d")
            day_of_week = current_date.weekday() # 0 = Segunda, 6 = Domingo
            
            # Puxar o "esqueleto" de aulas do SGA para este dia da semana específico
            template_lessons = self.weekly_schedule.get(day_of_week, [])
            daily_lessons = []
            
            for base_lesson in template_lessons:
                # Criar uma cópia isolada para não mutar o template base do SGA
                # model_copy é o padrão no Pydantic V2
                lesson_copy = base_lesson.model_copy(deep=True)
                
                # Buscar se o LLM extraiu algum conteúdo para esta matéria nesta data exata
                subject_syllabus = self.syllabus_data.get(base_lesson.subject_name, [])
                class_content = next((c for c in subject_syllabus if c.get("date") == date_str), None)
                
                if class_content:
                    # Match perfeito: O SGA diz que tem aula e o LLM sabe o que vai cair
                    lesson_copy.topic = class_content.get("topic")
                    lesson_copy.summary = class_content.get("summary")
                    lesson_copy.references = class_content.get("references", [])
                    lesson_copy.is_exam = class_content.get("is_exam", False)
                else:
                    # O SGA diz que tem aula, mas o professor não colocou nada específico no PDF
                    lesson_copy.topic = "Aula Normal (Sem tópico especificado)"
                
                daily_lessons.append(lesson_copy)
            
            # Só adicionamos o dia ao calendário final se houver aulas programadas (ignora fds/feriados sem aula)
            if daily_lessons:
                schedule_days.append(
                    DaySchedule(
                        date=date_str,
                        day_of_week=day_of_week,
                        lessons=daily_lessons
                    )
                )
            
            current_date += timedelta(days=1)

        return SemesterSchedule(
            semester="2026/1", # Isso pode ser inferido dinamicamente futuramente
            schedule=schedule_days
        )
