## 🛠️ Script em Destaque 2: Análise e Classificação de Vozeamento via F0

**Arquivo:** `proporcao_vozeamento.praat`

### 🎯 O problema que resolve
A avaliação acústica do vozeamento (como em fricativas ou plosivas) costuma ser desafiadora e carece de rigor quando baseada apenas na intuição visual do espectrograma ou em quedas de formantes (F1). Este script automatiza a detecção de vozeamento extraindo a presença de *Pitch* (F0) de forma iterativa, oferecendo uma medida acústica inquestionável baseada na atividade real das pregas vocais.

### ⚙️ Funcionalidades e Atributos Extraídos (Features)
O script varre arquivos pareados e processa os dados fonéticos gerando métricas adaptáveis à necessidade do pesquisador:
*   **Detecção Frame a Frame:** Cria um objeto de Pitch e avalia a presença de vibração glótica em janelas de 10 milissegundos dentro do segmento alvo.
*   **Cálculo Proporcional:** Retorna a porcentagem exata de vozeamento do segmento temporal (ex: 65.4%).
*   **Classificação Flexível:** Permite ao usuário escolher o rigor do tratamento dos dados:
    *   *Binário:* Classifica forçadamente como desvozeado ou vozeado com base em um limiar médio.
    *   *Ternário:* Estabelece limiares customizáveis (ex: < 20% e > 60%), rotulando automaticamente os casos que caem na zona de incerteza para revisão manual.
    *   *Gradual:* Mantém os rótulos originais, extraindo apenas o valor numérico (útil para regressões logísticas).
*   **Mutação Automática de Anotação:** Altera os rótulos originais (ex: de `s` para `z`) e cria dinamicamente uma nova camada (*tier*) no TextGrid para documentar a porcentagem extraída.
