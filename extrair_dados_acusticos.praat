form Configurações de Extração
comment Cole o caminho da pasta com os áudios e TextGrids:
text diretorio_base C:/caminho/para/sua/pasta/de/dados

comment Configurações do TextGrid (Número das camadas):
natural Ortho_tier 6
natural Word_tier 4
natural Syll_tier 2
natural Seg_tier 1

comment Configurações Acústicas:
boolean Extrair_formantes 0
comment (Use 5500 para vozes femininas/infantis e 5000 para vozes masculinas)
natural Frequencia_maxima_formantes 5500


endform

Ajuste do diretório para garantir que termina com a barra correta

if right$(diretorio_base$) <> "/" and right$(diretorio_base$) <> ""
diretorio_base$= diretorio_base$ + "/"
endif

directory$= diretorio_base$
resultfile$= directory$ + "all.txt"

filedelete 'resultfile$'
clearinfo

Montagem dinâmica do cabeçalho

header_row$ = "part" + tab$ + "ortholabel" + tab$ + "seglabel" + tab$ + "sylllabel" + tab$ + "wordlabel" + tab$  + "segdur" + tab$ + "sylldur" + tab$ + "worddur" + tab$ + "sentdur" + tab$ + "intmeanamp" + tab$ + "intmaxamp"

if extrair_formantes
header_row$= header_row$ + tab$ + "p75f1" + tab$ + "p75f2" + tab$ + "p75f3" + tab$ + "p80f1" + tab$ + "p80f2" + tab$ + "p80f3" + tab$ + "p85f1" + tab$ + "p85f2" + tab$ + "p85f3" + tab$ + "p90f1" + tab$ + "p90f2" + tab$ + "p90f3" + tab$ + "p95f1" + tab$ + "p95f2" + tab$ + "p95f3" + tab$ + "p100f1" + tab$ + "p100f2" + tab$ + "p100f3" + tab$ + "p105f1" + tab$ + "p105f2" + tab$ + "p105f3" + tab$ + "p110f1" + tab$ + "p110f2" + tab$ + "p110f3" + tab$ + "p115f1" + tab$ + "p115f2" + tab$ + "p115f3" + tab$ + "p120f1" + tab$ + "p120f2" + tab$ + "p120f3"
endif

header_row$ = header_row$+ newline$
fileappend "'resultfile$'" 'header_row$'

Variáveis das camadas recebem os valores do formulário

orthotier = ortho_tier
wordtier = word_tier
sylltier = syll_tier
segtier = seg_tier

Create Strings as file list...  list 'directory$'*.TextGrid
n_textgrids = Get number of strings

if !n_textgrids
exit There are no .TextGrid files in the folder!
endif

for ifile from 1 to n_textgrids
select Strings list
curr_file$ = Get string... 'ifile'
Read from file... 'directory$''curr_file$'
sn$= selected$ ("TextGrid")

# Get matching wav filename
base_name$= left$(curr_file$, length(curr_file$) - 9)
wav_file$= base_name$ + ".wav"

writeInfoLine: "Reading file 'curr_file$': 'ifile'/'n_textgrids'"

# Read wav
Read from file... 'directory$''wav_file$'
soundname$= selected$ ("Sound")

# Formant condicional
if extrair_formantes
	To Formant (burg)... 0 5 frequencia_maxima_formantes 0.025 50
	formantname$= selected$ ("Formant")
endif

# --- interval loops ---
select TextGrid 'sn$'

numint = Get number of intervals: wordtier
numint2 = numint - 1
for i from 1 to numint2
	wordlabel$ = Get label of interval: wordtier, i
	if wordlabel$ <> "" and wordlabel$ <> "_"
		wordstartint = Get start time of interval: wordtier, i
		wordendint = Get end time of interval: wordtier, i
		worddur = wordendint - wordstartint
		firstsyll = Get high interval at time: sylltier, wordstartint
		sylllabel$ = Get label of interval: sylltier, firstsyll
		syllstartint = wordstartint
		syllendint = Get end time of interval: sylltier, firstsyll
	
		nsyll = firstsyll
		sylldur = syllendint - syllstartint
	
		numortho = Get interval at time: orthotier, wordstartint
		ortholabel$ = Get label of interval: orthotier, numortho
		
		sentstartint = Get start time of interval: orthotier, numortho
		sentendint = Get end time of interval: orthotier, numortho
		sentdur = sentendint - sentstartint

		while syllendint <= wordendint
							
			firstseg = Get high interval at time: segtier, syllstartint
			seglabel$ = Get label of interval: segtier, firstseg
			segstartint = syllstartint
			segendint = Get end time of interval: segtier, firstseg

			nseg = firstseg	
			segdur = segendint - segstartint

			# Coleta de formantes apenas se habilitado
			formant_values$ = ""
			if extrair_formantes
				select Formant 'formantname$'
				
				tp = segstartint + (segdur * 0.75)
				p75f1 = Get value at time... 1 tp Hertz Linear
				p75f2 = Get value at time... 2 tp Hertz Linear
				p75f3 = Get value at time... 3 tp Hertz Linear

				tp = segstartint + (segdur * 0.80)
				p80f1 = Get value at time... 1 tp Hertz Linear
				p80f2 = Get value at time... 2 tp Hertz Linear
				p80f3 = Get value at time... 3 tp Hertz Linear

				tp = segstartint + (segdur * 0.85)
				p85f1 = Get value at time... 1 tp Hertz Linear
				p85f2 = Get value at time... 2 tp Hertz Linear
				p85f3 = Get value at time... 3 tp Hertz Linear

				tp = segstartint + (segdur * 0.90)
				p90f1 = Get value at time... 1 tp Hertz Linear
				p90f2 = Get value at time... 2 tp Hertz Linear
				p90f3 = Get value at time... 3 tp Hertz Linear

				tp = segstartint + (segdur * 0.95)
				p95f1 = Get value at time... 1 tp Hertz Linear
				p95f2 = Get value at time... 2 tp Hertz Linear
				p95f3 = Get value at time... 3 tp Hertz Linear

				tp = segstartint + (segdur * 1)
				p100f1 = Get value at time... 1 tp Hertz Linear
				p100f2 = Get value at time... 2 tp Hertz Linear
				p100f3 = Get value at time... 3 tp Hertz Linear

				tp = segstartint + (segdur * 1.05)
				p105f1 = Get value at time... 1 tp Hertz Linear
				p105f2 = Get value at time... 2 tp Hertz Linear
				p105f3 = Get value at time... 3 tp Hertz Linear

				tp = segstartint + (segdur * 1.10)
				p110f1 = Get value at time... 1 tp Hertz Linear
				p110f2 = Get value at time... 2 tp Hertz Linear
				p110f3 = Get value at time... 3 tp Hertz Linear

				tp = segstartint + (segdur * 1.15)
				p115f1 = Get value at time... 1 tp Hertz Linear
				p115f2 = Get value at time... 2 tp Hertz Linear
				p115f3 = Get value at time... 3 tp Hertz Linear

				tp = segstartint + (segdur * 1.2)
				p120f1 = Get value at time... 1 tp Hertz Linear
				p120f2 = Get value at time... 2 tp Hertz Linear
				p120f3 = Get value at time... 3 tp Hertz Linear
				
				formant_values$ = tab$ + "'p75f1'" + tab$ + "'p75f2'" + tab$ + "'p75f3'" + tab$ + "'p80f1'" + tab$ + "'p80f2'" + tab$ + "'p80f3'" + tab$ + "'p85f1'" + tab$ + "'p85f2'" + tab$ + "'p85f3'" + tab$ + "'p90f1'" + tab$ + "'p90f2'" + tab$ + "'p90f3'" + tab$ + "'p95f1'" + tab$ + "'p95f2'" + tab$ + "'p95f3'" + tab$ + "'p100f1'" + tab$ + "'p100f2'" + tab$ + "'p100f3'" + tab$ + "'p105f1'" + tab$ + "'p105f2'" + tab$ + "'p105f3'" + tab$ + "'p110f1'" + tab$ + "'p110f2'" + tab$ + "'p110f3'" + tab$ + "'p115f1'" + tab$ + "'p115f2'" + tab$ + "'p115f3'" + tab$ + "'p120f1'" + tab$ + "'p120f2'" + tab$ + "'p120f3'"
			endif

			# Amplitude
			select Sound 'soundname$'

			intmeanamp = Get mean... 0 'segstartint' 'segendint'
			intmaxamp = Get maximum... 'segstartint' 'segendint' Sinc70
				
			select TextGrid 'sn$'
		
			while segendint <= syllendint
				
				# Colar informações base
				outputLine$ = "'sn$'" + tab$ + "'ortholabel$'" + tab$ + "'seglabel$'" + tab$ + "'sylllabel$'" + tab$ + "'wordlabel$'" + tab$ + "'segdur'" + tab$ + "'sylldur'" + tab$ + "'worddur'" + tab$ + "'sentdur'" + tab$ + "'intmeanamp'" + tab$ + "'intmaxamp'"
				
				# Adiciona formantes se foram extraídos
				if extrair_formantes
					outputLine$ = outputLine$+ formant_values$
				endif
				
				appendFileLine: resultfile$, outputLine$

				# Incrementar o valor da label do segmento
				nseg = nseg + 1
				seglabel$ = Get label of interval: segtier, nseg
				segstartint = Get start time of interval: segtier, nseg
				segendint = Get end time of interval: segtier, nseg
				segdur = segendint - segstartint
			endwhile
		
			# Incrementar o valor da label da sílaba
			nsyll = nsyll + 1
			sylllabel$ = Get label of interval: sylltier, nsyll
			syllstartint = Get start time of interval: sylltier, nsyll
			syllendint = Get end time of interval: sylltier, nsyll			

			sylldur = syllendint - syllstartint
		endwhile
	endif		
endfor

# Limpar objetos para economizar memória (descomentado para evitar travamento)
select TextGrid 'sn$'
Remove
select Sound 'soundname$'
Remove
if extrair_formantes
	select Formant 'formantname$'
	Remove
endif


endfor

printline Script concluído com sucesso!
