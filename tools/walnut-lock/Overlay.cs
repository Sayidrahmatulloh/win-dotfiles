using System.Windows.Forms;
public sealed class WalnutOverlay : Form {
    public WalnutOverlay() {
        DoubleBuffered = true;
        SetStyle(ControlStyles.AllPaintingInWmPaint | ControlStyles.OptimizedDoubleBuffer | ControlStyles.UserPaint, true);
        AutoScaleMode = AutoScaleMode.None;
    }
    protected override void WndProc(ref Message message) {
        if (message.Msg == 0x14) { message.Result = new System.IntPtr(1); return; }
        base.WndProc(ref message);
    }
}
