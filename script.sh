#! /bin/bash
#Помещаем в переменную имена веток
branch=$(git branch --all --format='%(refname:short)')
#Исключения для обработки
exception=$(cat test.txt)
date=$(date +"%s")
#Обнуляем temp.txt
echo "" > temp.txt

#Убираем из обработки ветки, которые находятся в исключении
for Z in $branch;
do
#echo "Значение $Z"
    if echo ${exception[@]} | grep "$Z" ;
       then echo "$Z present in the array"
       else echo "$Z" >> temp.txt
fi
done

#Подгружаем имена веток, с которыми будем работать
processed=$(cat temp.txt)

#Делаем проверку на корректность наименования ветки
for i in $processed
 do
  #Проверяем, соответствует ли имя ветки регекспу
  if [ $i != 1 ]
  then
  #Если имя ветки не проходит проверку, то определяется mail последнего вносившего изменения и отправляем ему письмо 
  mail=$(git log $i --format='%ae' -n1) && echo "$i" >> test.txt
  #mail=$(git log $i --format='%ae' -n1) && echo "Переименуй" | mail -s "Необходимо переименовать ветку $i" -a "Сервер через который пойдет письмо" -r *От какой почты письмо* "$mail" && echo "$i" >> test.txt
  fi
  # Вычисляем время в Unix, когда последний раз обновлялась ветка
  datecom=$(git log $i --format='%ad' -n1 | awk "{NF--} 1") && time=$(date -d "$datecom" +"%s")
  #Если ветка не обновлялась более двух недель, то отсылаем письмо + убираем из обработки 
  if (( $date - $time  > 1209600 ))
  then echo "Время обновлять"
  #mail=$(git log $i --format='%ae' -n1) && echo "Необходимо обновить или удалить ветку $i" | mail -s "Обнови или удали $i" -a "Сервер через который пойдет письмо" -r *От какой почты письмо* "$mail" >> test.txt
  else echo "Еще не время обновлять"
  fi
done

