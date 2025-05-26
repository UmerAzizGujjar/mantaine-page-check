var iselLoaded = 0;
var iselTotalToLoad = 0;
var fnSelCallback = null;
function addToSelect(szID,szText,szValue)
{
    var elSel = $get(szID);
    var elOptNew = document.createElement('option');
    elOptNew.text = szText;
    elOptNew.value = szValue;
    
    try {
        elSel.add(elOptNew, null);  // non IE
    }
    catch(ex) {
        elSel.add(elOptNew);        // IE only
    }
}

function clearSelect(szID)
{
    var elSel = $get(szID);
    while(elSel.length > 0)
    {
        elSel.remove(elSel.length-1);
    }
}

function selectOption(szID,szValue)
{
    var bfound = false;
    var elSel = $get(szID);
    for(i=0;i<elSel.length;i++)
    {
        if(elSel.options[i].value == szValue)
        {
            elSel.selectedIndex = i;
            bfound = true;
        }
    }
    
    if (!bfound) {
        addToSelect(szID,szValue);
        elSel.selectedIndex = elSel.length-1;
    }
}

function selectValue(szID)
{
    return $get(szID).options[$get(szID).selectedIndex].value;
}

function setLoadCallback(fnCallback,inum)
{
    fnSelCallback = fnCallback;
    iselTotalToLoad = inum;
}

function loadSelect(szID, szType)
{
        srvSysLookup.GetLookups(szID,'HR',szType,On_loadSelect,onFail);
}

function On_loadSelect(aret)
{
    var ilen = parseInt(aret[0]);
    var szID = aret[1];
    
    clearSelect(szID);
    
    addToSelect(szID,'','');
    
    for(i=0;i<ilen;i++)
    {
        addToSelect(szID,aret[i+2],aret[i+2]);
    }
    iselLoaded++;
    
    if (iselLoaded >= iselTotalToLoad) {
        if (fnSelCallback != null) {
            fnSelCallback();
        }
    }
}

function loadEmployeeSelect(szID)
{
    srvMailDispatch.GetPeopleList(On_loadEmployeeSelect,function(exc){alert(exc.get_message());},szID);
}

function On_loadEmployeeSelect(aret,szID)
{
    var ilen = aret.length;
    
    clearSelect(szID);
    
    addToSelect(szID,'','');
    
    for(i=0;i<ilen;i++)
    {
        addToSelect(szID,aret[i],aret[i]);
    }
    iselLoaded++;
    
    if (iselLoaded >= iselTotalToLoad) {
        if (fnSelCallback != null) {
            fnSelCallback();
        }
    }
}

function onchange_DualOption(baseid)
{
    var oSel = document.getElementById('sel' + baseid);
    var oTxt = document.getElementById('txt' + baseid);
    
    if(oSel.selectedIndex > 0)
    {
        oTxt.disabled = true;
    }
    else
    {
        oTxt.disabled = false;
    }
}

function selectDualOption(baseid,szval)
{
    var oSel = document.getElementById('sel' + baseid);
    var oTxt = document.getElementById('txt' + baseid);
    
    var sdofound = false;
    for(sdo=0;sdo<oSel.length;sdo++)
    {
        if (oSel.options[sdo].value == szval) {
            if(sdo != 0)
            {
                sdofound = true;
                oSel.selectedIndex = sdo;
                onchange_DualOption(baseid);
                break;
            }
        }
    }
    
    if (sdofound == false) {
        oTxt.value = szval;
    }
}

function getvalueDualOption(baseid)
{
    var oSel = document.getElementById('sel' + baseid);
    var oTxt = document.getElementById('txt' + baseid);
    
    if(oSel.selectedIndex > 0)
    {
        return oSel.options[oSel.selectedIndex].value;
    }
    else
    {
        return oTxt.value;
    }
}