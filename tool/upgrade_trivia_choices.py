"""Add curated distractors to the existing 18 regional questions."""
import json
from pathlib import Path

distractors = [
 ['Luneta','Malacanang','Quiapo'],
 ['Chocolate Hills','Hundred Islands','Mayon Volcano'],
 ['Laoag','Dagupan','Alaminos'],
 ['Palawan','Cebu','Bohol'],
 ['Dahil sa maraming plantasyon ng niyog','Dahil sa malawak na palaisdaan','Dahil sa malaking produksyon ng kape'],
 ['Imus','Bacoor','Silang'],
 ['Callao Cave','Hinagdanan Cave','Sumaguing Cave'],
 ['Bulkang Taal','Bundok Arayat','Bundok Pinatubo'],
 ['Sinulog Festival','MassKara Festival','Panagbenga Festival'],
 ['Banaue Rice Terraces','Hundred Islands','Mayon Volcano'],
 ['Tulay ng Mactan-Mandaue','Tulay ng Buntun','Tulay ng Agas-Agas'],
 ['Dahil sa wikang Ilokano','Dahil sa wikang Nihongo','Dahil sa wikang Koreano'],
 ['Pagsanjan Falls','Kawasan Falls','Tinuy-an Falls'],
 ['Bundok Pulag','Bundok Banahaw','Bundok Makiling'],
 ['Inabel','Hablon','Pina'],
 ['Vinta','Paraw','Balsa'],
 ['Lawa ng Sebu','Lawa ng Mainit','Lawa ng Buluan'],
 ['Batas Republika Blg. 1425','Batas Republika Blg. 9165','Batas Republika Blg. 10175'],
]
path = Path('assets/data/trivia.json')
items = json.loads(path.read_text(encoding='utf-8'))
assert len(items) == len(distractors)
for index, (item, wrong) in enumerate(zip(items, distractors)):
    position = index % 4
    options = wrong.copy()
    options.insert(position, item['answer'])
    for letter, option in zip('abcd', options):
        item['option_' + letter] = option
    item['correct_option'] = position
    item['explanation'] = item['fun_fact']
path.write_text(json.dumps(items, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
