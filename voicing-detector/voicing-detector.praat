#################################################################################
# SCRIPT DE ANÁLISE DE PROPORÇÃO DE VOZEAMENTO (F0 / PITCH)
# Criado e adaptado por VITOR PRADO, UFMG (BR) (2025)
# Avaliação acústica robusta para dissertações baseada em proporção de frames vozeados
#################################################################################

form Configurações de Vozeamento
    comment Configurações de Diretório (Copie e cole do Windows normalmente)
    sentence Diretorio_de_entrada -
    sentence Diretorio_de_saida -
    
    comment Configurações do Alvo
    natural Tier_dos_fones 1
    word Alvo_desvozeado s
    
    comment Regra de Busca de Contexto
    choice Regra_de_Contexto 1
        button 1. Apenas contexto seguinte
        button 2. Apenas contexto anterior
        button 3. Ambos os contextos
        button 4. Ignorar contexto (qualquer ocorrencia do alvo)
        
    word Contexto_anterior a
    word Contexto_seguinte b
    
    comment Rótulos de Substituição
    word Substituto_vozeado z
    word Substituto_incerto s/z
    
    comment Método de Análise Acústica (% de frames com Pitch/F0)
    choice Tipo_de_Analise 1
        button 1. Binário (Desvozeado vs Vozeado)
        button 2. Ternário (Desvozeado, Incerto, Vozeado)
        button 3. Gradual (Apenas anota a porcentagem)
    
    comment Limiares de Decisão (porcentagem) - ignorados se usar a opção 3
    positive Limiar_Desvozeado_Ate_X 20
    positive Limiar_Vozeado_Acima_de_X 60
endform

writeInfoLine: "Iniciando extração..."

# Padronizar as barras dos diretórios (substitui \ por /)
diretorio_de_entrada$ = replace$ (diretorio_de_entrada$, "\", "/", 0)
diretorio_de_saida$ = replace$ (diretorio_de_saida$, "\", "/", 0)

# Garantir que os diretórios terminem com barra
if right$(diretorio_de_entrada$, 1) <> "/"
    diretorio_de_entrada$ = diretorio_de_entrada$ + "/"
endif
if right$(diretorio_de_saida$, 1) <> "/"
    diretorio_de_saida$ = diretorio_de_saida$ + "/"
endif

Create Strings as file list: "wavList", diretorio_de_entrada$ + "*.wav"
numberOfWavs = Get number of strings

for i from 1 to numberOfWavs
    selectObject: "Strings wavList"
    wavFile$ = Get string: i
    appendInfoLine: "Processando: ", wavFile$
    
    textGridFile$ = replace$ (wavFile$, ".wav", ".TextGrid", 0)
    
    Read from file: diretorio_de_entrada$ + wavFile$
    thisSound = selected("Sound")

    Read from file: diretorio_de_entrada$ + textGridFile$
    thisTextGrid = selected("TextGrid")
    
    selectObject: thisTextGrid
    numberOfTiers = Get number of tiers
    numberOfPhonemes = Get number of intervals: tier_dos_fones
        
    voicingtier = numberOfTiers + 1
    Insert interval tier: voicingtier, "voicing_percent"

    # EXTRAÇÃO DE F0 (PITCH)
    selectObject: thisSound
    thisPitch = To Pitch: 0.01, 75, 600
    
    for thisInterval from 1 to numberOfPhonemes
        selectObject: thisTextGrid
        thisPhoneme$ = Get label of interval: tier_dos_fones, thisInterval
        
        # Só prossegue se encontrou o fonema alvo
        if thisPhoneme$ = alvo_desvozeado$
            
            # Pega o contexto anterior com segurança (evita erro no 1º intervalo)
            if thisInterval > 1
                prevPhoneme$ = Get label of interval: tier_dos_fones, thisInterval - 1
            else
                prevPhoneme$ = ""
            endif
            
            # Pega o contexto seguinte com segurança (evita erro no último intervalo)
            if thisInterval < numberOfPhonemes
                nextPhoneme$ = Get label of interval: tier_dos_fones, thisInterval + 1
            else
                nextPhoneme$ = ""
            endif
            
            # AVALIAÇÃO DA REGRA DE CONTEXTO ESCOLHIDA
            contexto_valido = 0
            
            if regra_de_Contexto == 1 and nextPhoneme$ = contexto_seguinte$
                contexto_valido = 1
            elsif regra_de_Contexto == 2 and prevPhoneme$ = contexto_anterior$
                contexto_valido = 1
            elsif regra_de_Contexto == 3 and prevPhoneme$ = contexto_anterior$ and nextPhoneme$ = contexto_seguinte$
                contexto_valido = 1
            elsif regra_de_Contexto == 4
                contexto_valido = 1
            endif
            
            # Se o contexto bater com o que o usuário escolheu, faz a análise
            if contexto_valido == 1
                
                thisPhonemeStartTime = Get start point: tier_dos_fones, thisInterval
                thisPhonemeEndTime = Get end point: tier_dos_fones, thisInterval
                duration = thisPhonemeEndTime - thisPhonemeStartTime

                # CÁLCULO DA PROPORÇÃO DE VOZEAMENTO
                selectObject: thisPitch
                total_frames = 0
                voiced_frames = 0
                
                t = thisPhonemeStartTime
                while t <= thisPhonemeEndTime
                    total_frames = total_frames + 1
                    pitch_val = Get value at time: t, "Hertz", "Linear"
                    
                    if string$(pitch_val) <> "--undefined--"
                        voiced_frames = voiced_frames + 1
                    endif
                    
                    t = t + 0.01
                endwhile
                
                if total_frames > 0
                    porcentagem = (voiced_frames / total_frames) * 100
                else
                    porcentagem = 0
                endif
                
                porcentagem$ = fixed$ (porcentagem, 1) + "%"
                
                appendInfoLine: " - Segmento [", alvo_desvozeado$, "] processado. Vozeamento: ", porcentagem$

                # APLICAÇÃO DA LÓGICA ESCOLHIDA
                selectObject: thisTextGrid
                novo_rotulo$ = thisPhoneme$
                
                if tipo_de_Analise == 1 ; Binário
                    corte_binario = (limiar_Desvozeado_Ate_X + limiar_Vozeado_Acima_de_X) / 2
                    if porcentagem >= corte_binario
                        novo_rotulo$ = substituto_vozeado$
                    endif
                elsif tipo_de_Analise == 2 ; Ternário
                    if porcentagem >= limiar_Vozeado_Acima_de_X
                        novo_rotulo$ = substituto_vozeado$
                    elsif porcentagem > limiar_Desvozeado_Ate_X and porcentagem < limiar_Vozeado_Acima_de_X
                        novo_rotulo$ = substituto_incerto$
                    endif
                endif
                
                if tipo_de_Analise <> 3
                    Set interval text: tier_dos_fones, thisInterval, novo_rotulo$
                endif
                
                Insert boundary: voicingtier, thisPhonemeStartTime
                Insert boundary: voicingtier, thisPhonemeEndTime
                
                midPoint = thisPhonemeStartTime + (duration / 2)
                voicedint = Get interval at time: voicingtier, midPoint
                Set interval text: voicingtier, voicedint, porcentagem$
            endif
        endif
    endfor
    
    selectObject: thisTextGrid
    Save as text file: diretorio_de_saida$ + textGridFile$
    
    selectObject: thisSound, thisTextGrid, thisPitch
    Remove
endfor

selectObject: "Strings wavList"
Remove

appendInfoLine: newline$, "Whoo-hoo! Processamento completo! Arquivos salvos em: ", diretorio_de_saida$
