from typing import List, Optional, Dict, Any
from pydantic import BaseModel, Field

# ==========================================
# DATA CONTRACT (Pydantic Models V2)
# ==========================================

class Metadata(BaseModel):
    """Objeto flexível para expansão futura (notas, faltas, links) sem quebrar a UI."""
    custom_notes: str = ""
    grade: Optional[float] = None
    absence_count: int = 0

class Lesson(BaseModel):
    """Representação de uma aula num dia específico."""
    time_start: str
    time_end: str
    subject_id: str
    subject_name: str
    location: str
    
    # Dados injetados pelo LLM (Cronograma)
    topic: Optional[str] = None
    summary: Optional[str] = None
    references: List[str] = Field(default_factory=list)
    is_exam: bool = False
    
    metadata: Metadata = Field(default_factory=Metadata)

class DaySchedule(BaseModel):
    """Representação de um dia letivo com as suas respetivas aulas."""
    date: str  # Formato: YYYY-MM-DD
    day_of_week: int # 0 = Segunda, 6 = Domingo
    lessons: List[Lesson]

class SemesterSchedule(BaseModel):
    """O payload final que será lido pelo Flutter."""
    semester: str
    schedule: List[DaySchedule]
