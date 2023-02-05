
list=( "A" "B" "C" )
percentages=()

total="${#list[@]}"
percentages=()
index=0
for el in "${list[@]}"; do
  current="$(echo | awk "{print int($index * 1.00 * 100 / $total)}")"
  echo "index: ${index}"
  echo "current: ${current}"
  percentages+=( "${current}" )
  (( index++ )) || true
done

echo "total = ${total}"
echo "${percentages[@]}"

for el in "${list[@]}"; do
  dialog --gauge "Syncing ${el}" 8 30 0 <<< "${percentages[@]}"
  sleep 1
done


for i in 1 10 50 67 99 100; do echo "$i"; sleep 1; done | dialog --gauge "Syncing ..." 8 30 0

 <<< "$(for i in 1 10 50 67 99 100; do echo "$i"; sleep 1; done)"
