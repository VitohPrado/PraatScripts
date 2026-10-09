## 🛠️ Script em Destaque 1: Extração Acústica e Temporal Múltipla

**Arquivo:** `extrair_dados_acusticos.praat`

### 🎯 O problema que resolve
A coleta de dados fonéticos e acústicos é tradicionalmente feita de forma manual, um processo lento e altamente sujeito a falhas humanas. Este script resolve esse problema ao varrer um diretório inteiro contendo dezenas ou centenas de arquivos de áudio (`.wav`) e suas respectivas anotações estruturadas (`.TextGrid`), realizando extrações complexas em segundos.

### ⚙️ Funcionalidades e Atributos Extraídos (Features)
O script utiliza lógicas de iteração (`for`, `while`) e condicionais para navegar pelas camadas do arquivo de anotação e extrair dados em formato *Tidy* (`.txt` tabular). 

As seguintes variáveis são calculadas e exportadas automaticamente:
*   **Métricas Temporais:** Duração exata (em segundos) de segmentos, sílabas, palavras e sentenças.
*   **Métricas de Energia:** Amplitude média e amplitude máxima do sinal de áudio em intervalos específicos.
*   **Feature Engineering (Formantes Condicionais):** Coleta paramétrica dos 3 primeiros formantes (F1, F2, F3). O script calcula janelas móveis de tempo, extraindo dados de frequência a cada 5% de evolução temporal do segmento (de 75% a 120% da duração), permitindo análises de trajetória acústica fina.

### 🚀 Como utilizar
1. Baixe o arquivo `extrair_dados_acusticos.praat`.
2. Abra o software [Praat](https://www.fon.hum.uva.nl/praat/).
3. Vá em `Praat > Open Praat script...` e selecione o arquivo baixado.
4. Clique em `Run > Run` (ou use o atalho `Ctrl+R`).
5. Um formulário aparecerá. Cole o caminho absoluto da pasta onde estão seus pares de arquivos `.wav` e `.TextGrid` (ex: `C:/caminho/para/pasta`).
6. Ajuste as numerações das camadas (*tiers*) de acordo com a sua anotação e ative/desative a extração de formantes conforme necessário.
7. Clique em `Apply`. O arquivo resultante `all.txt` será gerado automaticamente na mesma pasta dos áudios.
