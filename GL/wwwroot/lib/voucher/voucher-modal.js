// GL voucher posted for one record (GRN, Goods Issuance, Stock Adjustment), shown in a modal.
// url: the page's WebMethod, e.g. "GoodsIssuanceNoteView.aspx/GetGINVoucherDetail"
// recordId / recordNo: the row's id and number
// modalId / bodyId / titleId: ids of the modal markup on the page
function showRecordVoucher(url, recordId, recordNo, modalId, bodyId, titleId) {
    var $body = $('#' + bodyId);
    $body.html('<div style="text-align:center;padding:30px;color:#888;"><i class="fa fa-spinner fa-spin"></i> Loading voucher&hellip;</div>');
    $('#' + titleId).text('Voucher' + (recordNo ? ' - ' + recordNo : ''));
    $('#' + modalId).modal({ backdrop: 'static' });

    $.ajax({
        type: 'POST',
        url: url,
        data: JSON.stringify({ recordId: recordId }),
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        success: function (response) {
            var d = JSON.parse(response.d);
            if (!d.lines || d.lines.length === 0) {
                $body.html('<div style="text-align:center;padding:40px 10px;color:#8a8f98;"><i class="fa fa-book" style="font-size:40px;color:#d5dae0;display:block;margin-bottom:10px;"></i>No voucher posted for this record</div>');
                return;
            }

            var lineRows = d.lines.map(function (l) {
                return '<tr><td>' + vmEsc(l.Account_Code) + '</td><td>' + vmEsc(l.Account_Name) + '</td>' +
                       '<td>' + vmEsc(l.Narration) + '</td>' +
                       '<td style="text-align:right;">' + vmMoney(l.DR) + '</td>' +
                       '<td style="text-align:right;">' + vmMoney(l.CR) + '</td></tr>';
            }).join('');

            var badge = d.status === 'Approved' ? '#1c7d43' : '#9a6700';
            var badgeBg = d.status === 'Approved' ? '#e7f6ec' : '#fff4e0';

            $body.html(
                '<div style="margin-bottom:10px;"><span style="font-size:11px;font-weight:800;padding:3px 11px;border-radius:11px;text-transform:uppercase;color:' + badge + ';background:' + badgeBg + ';">' + vmEsc(d.status || 'Unknown') + '</span></div>' +
                '<table class="table table-bordered table-condensed"><thead><tr><th>Account Code</th><th>Account</th><th>Narration</th>' +
                '<th style="text-align:right;">DR</th><th style="text-align:right;">CR</th></tr></thead>' +
                '<tbody>' + lineRows + '</tbody></table>'
            );
        },
        error: function () {
            $body.html('<div style="text-align:center;padding:40px 10px;color:#8a8f98;">Unable to load voucher.</div>');
        }
    });
}

function vmEsc(v) {
    return String(v == null ? '' : v)
        .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
}

function vmMoney(v) {
    if (v === null || v === undefined || v === '') { return ''; }
    return Number(v).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
}
