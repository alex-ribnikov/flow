setenv DB_NAME csvs
setenv POSTGRES_PASSWORD 6bd2fb4b
setenv POSTGRES_USER hw
setenv prompt ""
set _version = `pwd | tr "/" " " | awk '{print $(NF-1)}'`
set _run =  `pwd | tr "/" " " | awk '{print $NF}'`
set block_name = `pwd | tr "/" " " | awk '{print $(NF-2)}'`
set STAGE = $argv[1]
echo "_version: ${_version}"
echo "_run: ${_run}"
echo "block_name: ${block_name}"
echo "`date` - ${STAGE} - start stage ##########################################################################" >> grafana/grafana.log
echo "-I- wait for .${STAGE}_reports_done"
while ( ! -f .${STAGE}_reports_done)
    sleep 10
end
echo "-I- reports file exists. start runing stage: ${STAGE}"

# init HTML
echo "<html>" > grafana/${STAGE}_load_gifs.html
echo "<body>" >> grafana/${STAGE}_load_gifs.html
echo "<h2>Snapshots</h2>" >> grafana/${STAGE}_load_gifs.html

# upload GIFs to artifactory
echo "-I- uploading gif into artifactory"
echo "#################################################################################################"
setenv JFROG_USER becad
setenv JFROG_PASS Becad_123
echo "${STAGE} - going to upload the following images:" >> grafana/grafana.log

find reports/${STAGE}/snapshots |egrep '.gif|.png' > grafana/${STAGE}.gifs
foreach GIF (`find reports/${STAGE}/snapshots | egrep '.png|.gif'`)
  echo "${STAGE} - uploading gif into artifactory url: generic-repo/backend/${USER}/${block_name}/${_version}/${_run}/${STAGE}/${STAGE}_`basename ${GIF}`" >> grafana/grafana.log
  /tools/common/bin/cing-artifactory upload -src-artifact $GIF -dst-artifact generic-repo/backend/${USER}/${block_name}/${_version}/${_run}/${STAGE}/`basename ${GIF}` || echo "${STAGE} - failed to upload $GIF into artifactory" >> grafana/grafana.log
  setenv GIFNAME `basename ${GIF}|awk -F'.png' '{print $1}'` 
  echo "${STAGE} - adding gif ${GIFNAME} into html" >> grafana/grafana.log
  echo "<p>${GIFNAME}</p><img src='${GIFNAME}.png' alt='${GIFNAME}' width='500' height='333'>" >> grafana/${STAGE}_load_gifs.html
end

# close HTML
echo "</body>" >> grafana/${STAGE}_load_gifs.html
echo "</html>" >> grafana/${STAGE}_load_gifs.html

# STAGE Upload
echo "-I- uploading ${STAGE} CSV grafana/${block_name}_${STAGE}.csv file into DB" 
echo "#################################################################################################"
echo "${STAGE} - uploading ${STAGE} CSV grafana/${block_name}_${STAGE}.csv file into DB" >> grafana/grafana.log
echo "${STAGE} - running commnad: /tools/common/env/python3.10/bin/python ./scripts/bin/upload_csv.py -stage ${STAGE} -csv_file grafana/${block_name}_${STAGE}.csv" >> grafana/grafana.log
/tools/common/env/python3.10/bin/python ./scripts/bin/upload_csv.py -stage ${STAGE} -csv_file grafana/${block_name}_${STAGE}.csv || echo "${STAGE} - failed upload ${STAGE} CSV into DB" >> grafana/grafana.log
echo "${STAGE} CSV uploaded successfully" >> grafana/grafana.log

# STAGE group Upload
if (${STAGE} == "cts" || ${STAGE} == "route" || ${STAGE} == "place" || ${STAGE} == "compile") then
  echo "-I- uploading ${STAGE} CSV grafana/${block_name}_group_path_${STAGE}.csv file into DB" 
  echo "#################################################################################################"
  echo "${STAGE} - uploading ${STAGE} CSV grafana/${block_name}_group_path_${STAGE}.csv file into DB" >> grafana/grafana.log
  echo "${STAGE} - running commnad: /tools/common/env/python3.10/bin/python ./scripts/bin/upload_csv.py -group -stage ${STAGE} -csv_file grafana/${block_name}_group_path_${STAGE}.csv" >> grafana/grafana.log
  /tools/common/env/python3.10/bin/python ./scripts/bin/upload_csv.py -group -stage ${STAGE} -csv_file grafana/${block_name}_group_path_${STAGE}.csv || echo "${STAGE} - failed upload group ${STAGE} CSV into DB" >> grafana/grafana.log
  echo "${STAGE} group CSV uploaded successfully" >> grafana/grafana.log
endif

# upload HTML to artifactory
echo "-I- uploading HTML into artifactory"
echo "#################################################################################################"
echo "uploading HTML into artifactory url: generic-repo/backend/${USER}/${block_name}/${_version}/${_run}/${STAGE}/${STAGE}_load_gifs.html" >> grafana/grafana.log
/tools/common/bin/cing-artifactory upload -src-artifact grafana/${STAGE}_load_gifs.html -dst-artifact generic-repo/backend/${USER}/${block_name}/${_version}/${_run}/${STAGE}/ || echo "failed to upload load_gifs.html into artifactory" >> grafana/grafana.log
exit 0
