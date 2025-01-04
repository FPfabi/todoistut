.pragma library
.import QtQuick.LocalStorage 2.0 as Sql

var appPath = "";
var appName = "";

var db = Sql.LocalStorage.openDatabaseSync("todoistDB", "1.0", "TodoistDatabase", 100000);

var timeformat = "YYYY-MM-DD HH:MM:SS";


var eventsNotifier;



function init() {
    db.transaction(
        function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS History(id INTEGER PRIMARY KEY, timestamp STRING, event STRING);')
            tx.executeSql('CREATE TABLE IF NOT EXISTS Settings(id INTEGER PRIMARY KEY, name STRING UNIQUE, value STRING);')
        }
    )
    return "database created";
}

function purge() {
    try{
        db.transaction(
            function(tx) {
                tx.executeSql('DROP TABLE History;')
                tx.executeSql('DROP TABLE Settings;')
            }
        )
        init()
        return "database purged"
    }catch (e) {
        console.log(e)
    }
}


function updateSetting(keyName, newValue) {
    const sql = "UPDATE Settings SET value = '" + newValue + "' WHERE name = '" + keyName + "'";
    db.transaction(
    function(tx) {
        tx.executeSql(sql);
    }
    );
}

function getSetting(keyName){
    var records = []

    db.transaction(
        function(tx) {
            var searchString = "SELECT value from Settings s WHERE s.name = " + "'" + keyName + "';"  //STRFTIME('%d/%m/%Y, %H:%M', timestamp)
            var rs = tx.executeSql(searchString);
            console.log("[getSetting] Search string: " + searchString)
            for (var i = 0; i < rs.rows.length; i++) {
                var record = {
                    value: rs.rows.item(i).value
                }
                records.push(record);
                console.log("Setting: " + keyName + ":" + record.value);
            }
        }
    );

    if(records.length > 0){
        return records[0].value
    }else{
        console.log("Setting " + keyName + " could not be found!");
        return null;
    }
}

function settingExists(name){
    var existing = getSetting(name);
    if(existing !=null){
        return true;
    }else{
        return false;
    }
}


function addSetting2(name, value) {
    // if the key is already in the database, only update the existing key
    if (settingExists(name) == true){
        return db.updateSetting2(name, value);
    }

    console.log("Adding setting " + name + ", value: " + value);

    db.transaction(
        function(tx) {
            tx.executeSql(
                'INSERT INTO Settings VALUES(Null, ?, ?);',
                [name, value],
                function(tx, result) {
                    // Success callback
                    console.log('Row added successfully with ID: ' + result.insertId);
                },
                function(tx, error) {
                    // Error callback
                    console.error('Error occurred while adding row: ' + error.message);
                }
            );
        }
    );
}

function updateSetting2(name, newValue) {

    //if the setting does not exist yet, only add it to the table
    if (settingExists(name) == false){
        return addSetting2(name, newValue);
    }

    console.log("Updating setting " + name + ", value: " + newValue);

    db.transaction(
        function(tx) {
            tx.executeSql(
                'UPDATE Settings SET value = ? WHERE name = ?;',
                [newValue, name],
                function(tx, result) {
                    if (result.rowsAffected > 0) {
                        console.log('Row updated successfully.');
                    } else {
                        console.log('No row found with the given name.');
                    }
                },
                function(tx, error) {
                    // Error callback
                    console.error('Error occurred while updating row: ' + error.message);
                }
            );
        }
    );
}


function setup_dummy_events(){
    var now = new Date()
    var yesterday = addDays(now, -1)

    yesterday.setHours(12)
    yesterday.setMinutes(0)
    insertAtDate("Sleep Start", yesterday)

    yesterday.setHours(23)
    yesterday.setMinutes(59)
    insertAtDate("Sleep End", yesterday)

    var today = new Date()
    today.setHours(0)
    today.setMinutes(0)
    insertAtDate("Sleep Start", today)

    today.setHours(12)
    today.setMinutes(0)
    insertAtDate("Sleep End", today)


    //Insert Poop setup_dummy_events()
    /*
    yesterday.setHours(8)
    insertAtDate("Poop", yesterday)
    yesterday.setHours(yesterday.getHours() -1)
    insertAtDate("Poop", yesterday)

    var dmin2 = addDays(now, -2)
    dmin2.setHours(8)
    insertAtDate("Poop", dmin2)
    dmin2.setHours(dmin2.getHours() -1)
    insertAtDate("Poop", dmin2)

    var dmin3 = addDays(now, -3)
    dmin3.setHours(8)
    insertAtDate("Poop", dmin3)
    dmin3.setHours(dmin3.getHours() -1)
    insertAtDate("Poop", dmin3)

    var dmin4 = addDays(now, -4)
    dmin4.setHours(8)
    insertAtDate("Poop", dmin4)
    dmin4.setHours(dmin4.getHours() -1)
    insertAtDate("Poop", dmin4)
    */

}


function insertAtDate(strEvent, theDate){
    var sqllite_date = date_to_string2(theDate);
    console.log("[insertAtDate] Time:"  + sqllite_date)
    db.transaction(
        function(tx) {
            tx.executeSql('INSERT INTO History VALUES(Null, ?,?);', [sqllite_date, strEvent]);
        }
    );

}


function fill_sleep_at_time(strDateAround){

    //Both should return only one item in an array
    var evt_before = getEventBefore(strDateAround);
    var evt_after = getEventAfter(strDateAround);

    console.log("Before length: " + evt_before.length)
    console.log("After length: " + evt_after.length)


    if(evt_before.length >= 1 && evt_after.length >= 1){
        console.log("Before: " + evt_before[0].timestamp)
        console.log("After: " + evt_after[0].timestamp)

        var dt_start = string_to_date(evt_before[0].timestamp)
        dt_start.setMinutes(dt_start.getMinutes() + 10);

        var dt_end = string_to_date(evt_after[0].timestamp)
        dt_end.setMinutes(dt_end.getMinutes() - 10);

        console.log("New Start: " + dt_start)
        console.log("New End: " + dt_end)

        var diff = dt_end - dt_start;
        var minutes = Math.floor((diff/1000)/60);

        if(minutes > 10){
            insertRecord_On_Date("Sleep Start", date_to_string2(dt_start))
            insertRecord_On_Date("Sleep End", date_to_string2(dt_end))
            console.log("--> Insert successful")
            return {"status": "OK", "start": dt_start, "end": dt_end}
        }else{
            console.log("Error: Start and end time are too close. Diff minutes: "  + minutes)
            return {"status": "ERROR: Start and end time are too close", "start": dt_start, "end": dt_end}
        }

    }else{
        console.log("Error: There are no events enclosing the time " + strDateAround)
        return {"Status": "ERROR: There are no events enclosing the time " + strDateAround, "start": null, "end": null}
    }
}


function getEventBefore(strDate){
    var records = []

    db.transaction(
        function(tx) {
            var searchString = "SELECT id, timestamp, event FROM History h WHERE h.timestamp < datetime('" + strDate + "') order by timestamp DESC LIMIT 1;" //STRFTIME('%d/%m/%Y, %H:%M', timestamp)
            var rs = tx.executeSql(searchString);
            console.log("[getEventBefore] Search string: " + searchString)
            for (var i = 0; i < rs.rows.length; i++) {
                var record = {
                    id: rs.rows.item(i).id,
                    timestamp: rs.rows.item(i).timestamp,
                    event: rs.rows.item(i).event
                }
                records.push(record)
            }
        }
    );

    return records
}

function getEventAfter(strDate){
    var records = []

    db.transaction(
        function(tx) {
            var searchString = "SELECT id, timestamp, event FROM History h WHERE h.timestamp > datetime('" + strDate + "') order by timestamp ASC LIMIT 1;" //STRFTIME('%d/%m/%Y, %H:%M', timestamp)
            var rs = tx.executeSql(searchString);
            console.log("[getEventAfter] Search string: " + searchString)
            for (var i = 0; i < rs.rows.length; i++) {
                var record = {
                    id: rs.rows.item(i).id,
                    timestamp: rs.rows.item(i).timestamp,
                    event: rs.rows.item(i).event
                }
                records.push(record)
            }
        }
    );

    return records
}


function date_to_string(dt){
    console.log(dt.getHours())
    return dt.format(timeformat)
}
function date_to_string2(dt){
    var month = (dt.getMonth() + 1)
    var day = dt.getDate()
    var hour = dt.getHours() //(dt.getHours()+1)
    var minute = dt.getMinutes()
    var sec = dt.getSeconds()

    //Make sure double digit
    if(month<10){
        month = '0' + month;
    }
    if(day<10){
        day = '0' + day;
    }
    if(hour<10){
        hour = '0' + hour;
    }
    if(minute<10){
        minute = '0' + minute;
    }
    if(sec<10){
        sec = '0' + sec;
    }


    var ret = dt.getFullYear() + "-" + month + "-" + day + " " + hour + ":" + minute + ":" + sec;
    return ret;
}

function string_to_date(str_dt){
    var mydate = new Date(str_dt);
    return mydate
}


// Ignore entries older than lastHours parameter
function getRecords(lastHours) {
    var records = []

    var dt = new Date();
    dt.setHours(dt.getHours() - lastHours)
    var sqllite_date = date_to_string2(dt)

    db.transaction(
        function(tx) {
            var searchString = "SELECT id, timestamp, event FROM History h WHERE h.timestamp > date('" + sqllite_date + "') order by timestamp DESC;" //STRFTIME('%d/%m/%Y, %H:%M', timestamp)
            var rs = tx.executeSql(searchString);
            //console.log("[getRecords] Search string: " + searchString)
            for (var i = 0; i < rs.rows.length; i++) {
                var record = {
                    id: rs.rows.item(i).id,
                timestamp: rs.rows.item(i).timestamp,
                    event: rs.rows.item(i).event
                }
                records.push(record)
            }
        }
    );

    return records
}

function getSleepPeriodTemplate(){
    var sleep_period = {"start": null, "end": null, "duration": 0}
    return sleep_period
}

function addDays(date, days) {
  var result = new Date(date);
  result.setDate(result.getDate() + days);
  return result;
}

// Total of the day
function getMinutes(theDate){
    return (theDate.getHours()*60 + theDate.getMinutes())
}

// Return time string in this format HH:MM, eg. "09:35"
function getTimeString(theDate){
    var hour = theDate.getHours()
    var minute = theDate.getMinutes()


    return formatHoursMinutes(hour, minute)
}

// Return "00:00" as format
function formatHoursMinutes(hour, minute){
    var strHour = ""
    var strMin = ""
    if(hour< 10){
        strHour = "0" + hour
    }else{
        strHour = "" + hour
    }

    if(minute< 10){
        strMin = "0" + minute
    }else{
        strMin = "" + minute
    }

    return (strHour + ":" + strMin)

}


// Get all records from specific date
// Records are returned in ASCENDING order!!
// theDate: date object this time, not string!!
function getRecordsByDay(startDate, endDate) {
    var records = []

    var sqllite_start_date = date_to_string2(startDate) //2021-11-15 00:00
    var sqllite_end_date = date_to_string2(endDate) //2021-11-15 23:59

    var searchString = "";
    db.transaction(
        function(tx) {
            //var searchString = "SELECT id, timestamp, event FROM History h WHERE h.timestamp BETWEEN date('" + sqllite_start_date + "') AND date('" + sqllite_end_date + "') order by timestamp ASC;" //BEGING ASCENDING HERE!!
            searchString = "SELECT id, timestamp, event FROM History h WHERE h.timestamp BETWEEN '" + sqllite_start_date + "' AND '" + sqllite_end_date + "' order by timestamp ASC;"
            var rs = tx.executeSql(searchString);
            //console.log("[getRecords] Search string: " + searchString)
            for (var i = 0; i < rs.rows.length; i++) {
                var record = {
                    id: rs.rows.item(i).id,
                    timestamp: rs.rows.item(i).timestamp,
                    event: rs.rows.item(i).event
                }
                records.push(record)
            }
        }
    );
    if(records.length == 0){
        console.log("[getRecordsByDay] No records found for search string " + searchString)
    }

    return records;
}

// Ignore entries older than lastHours parameter
// eventFilters must be an array e.g. ['Pee', 'Poop']
// Sortet from newest to oldest
function getRecordsByEvent(eventFilters) {
    var records = []

    for (var i = 0; i < eventFilters.length; i++) {
        eventFilters[i] = "'" + eventFilters[i] + "'"
    }

    var filterListString = eventFilters.join(", ")

    var searchString = "";
    db.transaction(
        function(tx) {
            searchString = "SELECT id, timestamp, event FROM History h WHERE h.event IN (" + filterListString + ") order by timestamp DESC;" //STRFTIME('%d/%m/%Y, %H:%M', timestamp)
            //console.log("[getRecordsByEvent] sql query: " + searchString)
            var rs = tx.executeSql(searchString);
            //console.log("[getRecords] Search string: " + searchString)
            for (var i = 0; i < rs.rows.length; i++) {
                var record = {
                    id: rs.rows.item(i).id,
                    timestamp: rs.rows.item(i).timestamp,
                    event: rs.rows.item(i).event
                }
                records.push(record)
            }
        }
    );
    if(records.length == 0){
        console.log("[getRecordsByEvent] No records found for search string " + searchString)
    }

    return records
}

// Get the newest one based on dateTime entry
function getLatestRecord() {
    var records = []

    db.transaction(
        function(tx) {
            var searchString = "SELECT id, timestamp, event FROM History h order by timestamp DESC LIMIT 1;" //STRFTIME('%d/%m/%Y, %H:%M', timestamp)
            console.log("[getRecordsByEvent] sql query: " + searchString)
            var rs = tx.executeSql(searchString);
            console.log("[getRecords] Search string: " + searchString)
            for (var i = 0; i < rs.rows.length; i++) {
                var record = {
                    id: rs.rows.item(i).id,
                timestamp: rs.rows.item(i).timestamp,
                    event: rs.rows.item(i).event
                }
                records.push(record)
            }
        }
    );

    return records
}

function latestIsPeeOrPoop(){
    var records = getLatestRecord()
    if(records==null){
        return false;
    }

}

// returns id and date diff for latest Pee or Poop event
function getLatestPeePoop(){
    var records = getRecordsByEvent(['Pee', 'Poop', 'Pee, Poop']);
    if(records.length == 0){
        console.log("[getLatestPeePoop] No event found in database")
        return null;
    }

    var latest = records[0];
    var diff = getDateDiff(latest.timestamp)
    return {'id': latest.id, 'days': diff.days, 'hours': diff.hours, 'minutes': diff.minutes}
}

// returns id and date diff for latest Poop event
function getLatestPoop(){
    var records = getLatestEventByWildCard("Poop");

    if(records == null){
        return {'id': -1, 'days': -1, 'hours': -1, 'minutes': -1}
    }

    if(records.length == 0){
        console.log("[getLatestPoop] No event found in database")
        return null;
    }

    var latest = records[0];

    if(latest == null){
        return {'id': -1, 'days': -1, 'hours': -1, 'minutes': -1}
    }

    var diff = getDateDiff(latest.timestamp)
    return {'id': latest.id, 'days': diff.days, 'hours': diff.hours, 'minutes': diff.minutes}
}

// returns id and date diff for latest Poop event
function getLatestPee(){
    var records = getLatestEventByWildCard("Pee");

    if(records == null){
        return {'id': -1, 'days': -1, 'hours': -1, 'minutes': -1}
    }

    if(records.length == 0){
        console.log("[getLatestPee] No event found in database")
        return null;
    }

    var latest = records[0];

    if(latest == null){
        return {'id': -1, 'days': -1, 'hours': -1, 'minutes': -1}
    }

    var diff = getDateDiff(latest.timestamp)
    return {'id': latest.id, 'days': diff.days, 'hours': diff.hours, 'minutes': diff.minutes}
}


// Get the newest one based on dateTime entry
function getLatestEventByWildCard(eventName) {
    var records = []

    db.transaction(
        function(tx) {
            var searchString = "SELECT id, timestamp, event FROM History h WHERE h.event LIKE '%" + eventName + "%' order by timestamp DESC LIMIT 1;" //STRFTIME('%d/%m/%Y, %H:%M', timestamp)
            console.log("[getRecordsByEvent] sql query: " + searchString)
            var rs = tx.executeSql(searchString);
            console.log("[getRecords] Search string: " + searchString)
            for (var i = 0; i < rs.rows.length; i++) {
                var record = {
                    id: rs.rows.item(i).id,
                timestamp: rs.rows.item(i).timestamp,
                    event: rs.rows.item(i).event
                }
                records.push(record)
            }
        }
    );

    console.log("[getLatestEventByWildCard] No. of records found: " + records.length)
    if(records.length > 0){
        return records[0]
    }else{
        return null;
    }
}


//Get the array with the records that match the id,  provided the id of the record
function getRecordsById(recordId) {
    var records = []

    db.transaction(
        function(tx) {
            var searchString = "SELECT id, timestamp, event FROM History h WHERE h.id = " + recordId + ";" //STRFTIME('%d/%m/%Y, %H:%M', timestamp)
            var rs = tx.executeSql(searchString);
            console.log("[getRecords] Search string: " + searchString)
            for (var i = 0; i < rs.rows.length; i++) {
                var record = {
                    id: rs.rows.item(i).id,
                timestamp: rs.rows.item(i).timestamp,
                    event: rs.rows.item(i).event
                }
                records.push(record)
            }
        }
    );

    return records;
}


function insertRecord(strEvent) {
    // Sanity check: was the same event added just now? Then reject
    var similiarEvent = getLatestEventByWildCard(strEvent)
    if(similiarEvent!=null){
        var diffToSim = getDateDiff(similiarEvent.timestamp)

        if(diffToSim.days == 0 && diffToSim.hours == 0 && diffToSim.minutes <=1){
            console.log("[insertRecord] SANITY CHECK: Event '" + strEvent + "' was already added just now; Recejecting...")
            return -1
        }
    }

    //Next check: If Pee and Poop are added in very short time frame, combine them into "Pee, Poop" event entry instead of adding a new getLatestRecord()
    var mergeID = canCombinePeePoop(strEvent)
    if(mergeID > -1){
        console.log("[insertRecord] Merging the events...")
        setRecordPeePoop(mergeID)
        return mergeID
    }


    //var thetime = new Date().toString()
    var sqllite_date = date_to_string2(new Date());// new Date().toISOString();
    console.log("[insertRecord] Time:"  + sqllite_date)
    db.transaction(
        function(tx) {
            tx.executeSql('INSERT INTO History VALUES(Null, ?,?);', [sqllite_date, strEvent ]);
        }
    );

    var newId = getLatestRecordId()
    console.log("[insertRecord] New Id: " + newId)

    return newId;
}

function insertRecord_On_Date(strEvent, strDate){
    db.transaction(
        function(tx) {
            tx.executeSql('INSERT INTO History VALUES(Null, ?,?);', [strDate, strEvent ]);
        }
    );

    var newId = getLatestRecordId()
    console.log("[insertRecord_On_Date] New Id: " + newId)

    return newId;

}


//If possible, returns the ID of the record to modify
function canCombinePeePoop(strNewEntry){
    var mergeEvent = null
    if(strNewEntry == "Pee"){
        mergeEvent = getLatestEventByWildCard("Poop")
    }else if(strNewEntry == "Poop"){
        mergeEvent = getLatestEventByWildCard("Pee")
    }else{
        return -1; //Combine events only for Pee+Poop
    }

    if(mergeEvent!=null){
        var diffToSim = getDateDiff(mergeEvent.timestamp)

        if(diffToSim.days == 0 && diffToSim.hours == 0 && diffToSim.minutes <=3){
            console.log("[canCombinePeePoop] Found event to merge: '" + mergeEvent.event + "' with " + strNewEntry)
            return mergeEvent.id
        }
    }
}

// When there is already a "Pee" record in the last minute and Poop is inserted it gets added to the record by modifying event to "Pee, Poop"
function setRecordPeePoop(id) {
    //var thetime = new Date().toString()
    var sqllite_date = date_to_string2(new Date());// new Date().toISOString();
    console.log("[insertRecord] Time:"  + sqllite_date)
    db.transaction(
        function(tx) {
            tx.executeSql("UPDATE History SET event = 'Pee, Poop' WHERE id = " + id + ";");
        }
    );

    var newId = getLatestRecordId()
    console.log("[insertRecord] New Id: " + newId)

    return newId;
}



function getLatestRecordId(){
    var records = []

    db.transaction(
        function(tx) {
            var searchString = "SELECT Max(id) as max_id from History;" //STRFTIME('%d/%m/%Y, %H:%M', timestamp)
            var rs = tx.executeSql(searchString);
            console.log("[getRecords] Search string: " + searchString)
            for (var i = 0; i < rs.rows.length; i++) {
                var record = {
                    id: rs.rows.item(i).max_id
                }
                records.push(record)
            }
        }
    );

    if(records.length > 0){
        return records[0].id

    }else{
        return -1
    }
}

function removeRecord(id) {
    db.transaction(
        function(tx) {
            tx.executeSql('DELETE FROM History WHERE id=?;', [ id ]);
        }
    );
}

//time dmin is delta minutes
// Assuming that dmin can be positive or negative, we get the new date by curDate.setMinutes(dt.getMinutes() + dmin)
// +++++++ VERY IMPORTANT: Update command must be SET timestamp = datetime('" + new_sqllite_date + "')... instead of ...date(...    --> datetime instead of date!!!!
function modifyTime(recordId, dmin){
    //Get current date of record
    var curDate = new Date(getRecordsById(recordId)[0].timestamp);
    console.log("[modifyTime] Current DB date: " + curDate.toString())
    //Add the minutes
    //curDate.setMinutes(curDate.getMinutes() + dmin);
    var minutesModDate = new Date( curDate.getTime() + 1000 * 60 * dmin);
    console.log("[modifyTime] new date: " + minutesModDate.toString())
    //convert to string
    var new_sqllite_date = date_to_string2(minutesModDate);
    console.log("[modifyTime] new sqlite date: " + new_sqllite_date)

    // SQL update command
    var sqlString = "UPDATE History SET timestamp = datetime('" + new_sqllite_date + "') WHERE id=" + recordId + ";"

    console.log("[modifyTime] sql update string: " + sqlString)

    db.transaction(function(tx) {
        tx.executeSql(sqlString);
    });
}

//Removes the seconds info from the date string
function formatDateForDisplay(fullDateString){
    return fullDateString.substring(0, fullDateString.length-3);
}


function getDateDiffString(oldDateString){
    var dateDiff = getDateDiff(oldDateString)

    if(dateDiff.days > 0){
        if(dateDiff.hours < 8){
            return(dateDiff.days + " days ago")
        }else if(dateDiff.hours < 17){
            return(dateDiff.days + ".5 days ago")
        }else if(dateDiff.hours < 23){
            return((dateDiff.days+1) + " days ago")
        }

        return(dateDiff.days + " days ago")
    }

    if(dateDiff.hours > 0){
        if(dateDiff.minutes <= 20){
            return(dateDiff.hours + " hours ago")
        }else if(dateDiff.minutes <= 40){
            return(dateDiff.hours + ".5 hours ago")
        }else if(dateDiff.minutes <= 60){
            return((dateDiff.hours +1) + " hours ago")
        }else{
            return dateDiff.hours + ":" + dateDiff.minutes  //return(dateDiff.hours + " hours ago")
        }
    }

    if(dateDiff.minutes > 2){
        return(dateDiff.minutes + " min ago")
    }

    return "now"
}

// Returns dictionary with date difference in days, hours, minutes
// Parameter: Date as String
function getDateDiff(oldDateString){
    var oldDate = new Date(oldDateString);
    console.log(typeof oldDate);
    var now = new Date();
    var diffMs = (now - oldDate); // milliseconds between now & Christmas

    var diffDays = Math.floor(diffMs / 86400000); // days
    var diffHrs = Math.floor((diffMs % 86400000) / 3600000); // hours
    var diffMins = Math.round(((diffMs % 86400000) % 3600000) / 60000); // minutes

    return {'days':diffDays, 'hours': diffHrs, 'minutes': diffMins}

}


//Reutns time in minutes between dates
function getMinutesBetweenDates(lateTimeString, earlyTimeString){
    var earlyDate = new Date(earlyTimeString);
    console.log(typeof oldDate);
    var lateDate = new Date(lateTimeString);
    var diffMs = (lateDate - earlyDate); // milliseconds between now & Christmas

    return (diffMs / (1000*60)) //return duration in minutes
}


function formatDateTime(sDate,FormatType) {
    var lDate = new Date(sDate)

    var month=new Array(12);
    month[0]="January";
    month[1]="February";
    month[2]="March";
    month[3]="April";
    month[4]="May";
    month[5]="June";
    month[6]="July";
    month[7]="August";
    month[8]="September";
    month[9]="October";
    month[10]="November";
    month[11]="December";

    var weekday=new Array(7);
    weekday[0]="Sunday";
    weekday[1]="Monday";
    weekday[2]="Tuesday";
    weekday[3]="Wednesday";
    weekday[4]="Thursday";
    weekday[5]="Friday";
    weekday[6]="Saturday";

    var hh = lDate.getHours() < 10 ? '0' +
        lDate.getHours() : lDate.getHours();
    var mi = lDate.getMinutes() < 10 ? '0' +
        lDate.getMinutes() : lDate.getMinutes();
    var ss = lDate.getSeconds() < 10 ? '0' +
        lDate.getSeconds() : lDate.getSeconds();

    var d = lDate.getDate();
    var dd = d < 10 ? '0' + d : d;
    var yyyy = lDate.getFullYear();
    var mon = lDate.getMonth()+1;
    var mm = (mon<10?'0'+mon:mon);
    var monthName=month[lDate.getMonth()];
    var weekdayName=weekday[lDate.getDay()];

    if(FormatType==1) {
       return mm+'/'+dd+'/'+yyyy+' '+hh+':'+mi;
    } else if(FormatType==2) {
       return weekdayName+', '+monthName+' '+
            dd +', ' + yyyy;
    } else if(FormatType==3) {
       return mm+'/'+dd+'/'+yyyy;
    } else if(FormatType==4) {
       var dd1 = lDate.getDate();
       return dd1+'-'+ monthName.substring(0,3) +'-' + yyyy;
    } else if(FormatType==5) {
        return mm+'/'+dd+'/'+yyyy+' '+hh+':'+mi+':'+ss;
    } else if(FormatType == 6) {
        return mon + '/' + d + '/' + yyyy + ' ' +
            hh + ':' + mi + ':' + ss;
    } else if(FormatType == 7) {
        return  dd + '-' + monthName.substring(0,3) +
            '-' + yyyy + ' ' + hh + ':' + mi + ':' + ss;
    } else if(FormatType == 8) {
        return  monthName.substring(0,3) + '-' + dd + ' ' + hh + ':' + mi;
    }else if(FormatType == 9) {
        // Nov 7
        return  monthName.substring(0,3) + ' ' + dd;
    }
}
