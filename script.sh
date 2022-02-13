#! /bin/bash
#Помещаем в переменную имена веток
branch=$(git branch --all --format='%(refname:short)')
#Исключения для обработки
exception=$(cat exception.txt)
#Текущее время в Unix
date=$(date +"%s")
#Обнуляем temp.txt
echo "" > temp.txt

#Убираем из обработки ветки, которые находятся в исключении
for Z in $branch;
do
#echo "Значение $Z"
  if echo ${exception[@]} | grep "$Z" ;
    then echo "$Z present in the array"
    else echo "$Z" >> temp.txt #Заносим данные в файл, для дальнейшей обработки
  fi
done

#Подгружаем имена веток, с которыми будем работать
processed=$(cat temp.txt)

#Делаем проверку на корректность наименования ветки
for i in $processed
 do
  #Проверяем, соответствует ли имя ветки регекспу
   if [[ $i =~ ^(bugfix|feature)-task-[0-9] ]]
     then
       echo "Все ок, ветка $i соответвует"
     else
     #Если имя ветки не проходит проверку, то определяется mail последнего вносившего изменения и отправляем ему письмо
     email=$(git log $i --format='%ae' -n1) && echo "Ветка $i не прошла проверку, письмо последнему контрибутору - $email" #exception.txt
     #mail=$(git log $i --format='%ae' -n1) && echo "Переименуй" | mail -s "Необходимо переименовать ветку $i" -a "Сервер через который пойдет письмо" -r *От какой почты письмо* "$mail" && echo "$i" >> exception.txt
   fi
   # Вычисляем время в Unix, когда последний раз обновлялась ветка
   datecom=$(git log $i --format='%at' -n1)
   #Если ветка не обновлялась более двух недель, то отсылаем письмо + убираем из обработки
   if (( $date - $datecom > 1209600 ))
     then email2=$(git log $i --format='%ae' -n1) && echo "Время обновлять, письмо на $email2"
     #mail=$(git log $i --format='%ae' -n1) && echo "Необходимо обновить или удалить ветку $i" | mail -s "Обнови или удали $i" -a "Сервер через который пойдет письмо" -r *От какой почты письмо* "$mail" >> exception.txt
     #else echo "Еще не время обновлять"
   fi
done
